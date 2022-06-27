#!/bin/bash
function service_token_generation() {
	payload="{\"token_tenant_id\": \"admin\", \"account_type\":\"service\" , \"token_username\": \"streams\" , \"target_site_id\": \"tacc\" }"
	RESULT=`curl -u "streams:$streams_pass" -H "Content-type: application/json"  -d "$payload" $admin_base_url/v3/tokens 2>/dev/null`
	service_token=`echo $RESULT | jq -r '.result.access_token.access_token'`
  if [ $service_token = 'null' ]; then
		echo "Service token generation failed for streams in tenant admin"
		break
	fi
			
	
}


###: Function to load configurations per tenant
function load_config () {
	CONFIG=`cat /config.json`
	case $tenant_name in 
    dev)
      base_url=`echo $CONFIG | jq -r '.dev.base_url'`
      pass=`echo $CONFIG | jq -r '.dev.pass'`
      user=`echo $CONFIG | jq -r '.dev.user'`
      service_pass=`echo $CONFIG | jq -r '.dev.service_pass'`
      db=`echo $CONFIG | jq -r '.dev.db'`
      streams_pass=`echo $CONFIG | jq -r '.dev.streams_pass'`
      tenant=`echo $CONFIG | jq -r '.dev.tenant'`
      admin_base_url=`echo $CONFIG | jq -r '.dev.admin_base'`
      system=`echo $CONFIG | jq -r '.dev.system'`

      ;;

    assoc)
      base_url=`echo $CONFIG | jq -r '.assoc.base_url'`
      pass=`echo $CONFIG | jq -r '.assoc.pass'`
      user=`echo $CONFIG | jq -r '.assoc.user'`
      service_pass=`echo $CONFIG | jq -r '.assoc.service_pass'`
      db=`echo $CONFIG | jq -r '.assoc.db'`
      streams_pass=`echo $CONFIG | jq -r '.assoc.streams_pass'`
      tenant=`echo $CONFIG | jq -r '.assoc.tenant'`
      admin_base_url=`echo $CONFIG | jq -r '.assoc.admin_base'`
      system=`echo $CONFIG | jq -r '.assoc.system'`

      ;;

	*)
		echo "  "
		echo "**********************************************************"
		echo " "
		echo "Please enter a valid tenant name: dev all"
		echo " "
		echo "**********************************************************"
		break
		;;
	esac
}



### Function containing smoke tests for all services
function smoke_tests() {
#: total_core_tests, total_core_pass, total_core_fail are cumulative statistics for all services
	total_core_test=$((total_core_test+num_of_tests))
	total_core_pass=$((total_core_pass+num_of_tests_pass))
	total_core_fail=$((total_core_fail+num_of_tests_fail))

	#: num_of_tests, num_of_tests_pass, num_of_tests_fail are tests per service
	num_of_tests=0
	num_of_tests_pass=0
	num_of_tests_fail=0


	#: Run smoke tests per command line arguement given in -s or --service
	while :
	do
		flag_tests_fail=false
		case $core_service in
		#: Smoke tests for streams service
		streams)
			echo "  "
			#echo "**********************************************************"
			#echo " "
			echo "Streams: "
			echo "-------- "
			echo "Test: List projects"
			header=`echo X-Tapis-token:$user_token`
			RESULT=`curl -o /dev/null -w '%{http_code}' -H "$header" $base_url/v3/streams/projects 2>/dev/null`
			echo $RESULT
            num_of_tests=$((num_of_tests+1))
            #echo $num_of_tests
            if [ $RESULT = '200' ]; then
            	num_of_tests_pass=$((num_of_tests_pass+1))
            	echo "PASS"
			else
				num_of_tests_fail=$((num_of_tests_fail+1))
				echo "FAIL"
			fi
			echo " "
			echo "Test: Hello"
			RESULT=`curl -o /dev/null -w '%{http_code}'  $base_url/v3/streams/hello 2>/dev/null`
			echo $RESULT
            num_of_tests=$((num_of_tests+1))
            #echo $num_of_tests

            if [ $RESULT = '200' ]; then
            	num_of_tests_pass=$((num_of_tests_pass+1))
            	echo "PASS"
			else
				num_of_tests_fail=$((num_of_tests_fail+1))
				echo "FAIL"
			fi
			echo " "
			echo "Test: Ready"
			RESULT=`curl -o /dev/null -w '%{http_code}'  $base_url/v3/streams/ready 2>/dev/null`
			echo $RESULT
            num_of_tests=$((num_of_tests+1))
            #echo $num_of_tests

            if [ $RESULT = '200' ]; then
            	num_of_tests_pass=$((num_of_tests_pass+1))
            	echo "PASS"
			else
				num_of_tests_fail=$((num_of_tests_fail+1))
				echo "FAIL"
			fi
			break
			echo " "
			echo "Test: healtheck "
			RESULT=`curl -o /dev/null -w '%{http_code}'  $base_url/v3/streams/healthcheck?tenant=$tenant 2>/dev/null`
			echo $RESULT
            num_of_tests=$((num_of_tests+1))
            echo $num_of_tests

            if [ $RESULT = '200' ]; then
            	num_of_tests_pass=$((num_of_tests_pass+1))
            	echo "PASS"
			else
				num_of_tests_fail=$((num_of_tests_fail+1))
				echo "FAIL"
			fi
			break
			;;

		#: Smoke tests for security Kernel service
	    sk)
			echo " "
			echo "**********************************************************"
			echo " "
			echo "SK:"
			echo "------ "
			echo " "
			header=`echo X-Tapis-token:$user_token`
			echo "Test: Hello"
			RESULT=`curl -o /dev/null -w '%{http_code}'  $base_url/v3/security/hello 2>/dev/null`
			echo $RESULT
            num_of_tests=$((num_of_tests+1))

            if [ $RESULT = '200' ]; then
            	num_of_tests_pass=$((num_of_tests_pass+1))
            	echo "PASS"
			else
				num_of_tests_fail=$((num_of_tests_fail+1))
				echo "FAIL"
			fi
			echo""
			echo "Test: Healthcheck"
			RESULT=`curl -o /dev/null -w '%{http_code}'  $base_url/v3/security/healthcheck 2>/dev/null`
			echo $RESULT
            num_of_tests=$((num_of_tests+1))

            if [ $RESULT = '200' ]; then
            	num_of_tests_pass=$((num_of_tests_pass+1))
            	echo "PASS"
			else
				num_of_tests_fail=$((num_of_tests_fail+1))
				echo "FAIL"
			fi
			echo""
			echo "Test: List Role names"
			RESULT=`curl -o /dev/null -w '%{http_code}'  -H "$header" $base_url/v3/security/role?tenant=$tenant 2>/dev/null`
			echo $RESULT
            num_of_tests=$((num_of_tests+1))
            if [ $RESULT = '200' ]; then
            	num_of_tests_pass=$((num_of_tests_pass+1))
            	echo "PASS"
			else
				num_of_tests_fail=$((num_of_tests_fail+1))
				echo "FAIL"
			fi
			break
			;;
			#: Smoke tests for systems service
	        systems)
			echo " "
			echo "**********************************************************"
			echo " "
			echo "Systems:"
			echo "------ "
			echo "List Systems"
			header=`echo X-Tapis-token:$user_token`
			RESULT=`curl -o /dev/null -w '%{http_code}' -H "$header" $base_url/v3/systems 2>/dev/null`
			echo $RESULT
            num_of_tests=$((num_of_tests+1))
            if [ $RESULT = '200' ]; then
            	num_of_tests_pass=$((num_of_tests_pass+1))
            	echo "PASS"
			else
				num_of_tests_fail=$((num_of_tests_fail+1))
				echo "FAIL"
			fi
			echo "------ "
			#echo "Get System details"
			##RESULT=`curl -o /dev/null -w '%{http_code}' -H "$header" $base_url/v3/systems/$system 2>/dev/null`
			#echo $RESULT
      #      num_of_tests=$((num_of_tests+1))
      #      if [ $RESULT = '200' ]; then
      #      	num_of_tests_pass=$((num_of_tests_pass+1))
      #      	echo "PASS"
			#else
			#	num_of_tests_fail=$((num_of_tests_fail+1))
			#		echo "FAIL"
			#fi
			echo "------"
			echo "Test: Healthcheck"
			RESULT=`curl -o /dev/null -w '%{http_code}' $base_url/v3/systems/healthcheck 2>/dev/null`
			echo $RESULT
            num_of_tests=$((num_of_tests+1))
            if [ $RESULT = '200' ]; then
            	num_of_tests_pass=$((num_of_tests_pass+1))
            	echo "PASS"
			else
				num_of_tests_fail=$((num_of_tests_fail+1))
				echo "FAIL"
			fi
			echo "------"
			echo "Test: Readycheck"
			RESULT=`curl -o /dev/null -w '%{http_code}'  $base_url/v3/systems/readycheck 2>/dev/null`
			echo $RESULT
            num_of_tests=$((num_of_tests+1))
            if [ $RESULT = '200' ]; then
            	num_of_tests_pass=$((num_of_tests_pass+1))
            	echo "PASS"
			else
				num_of_tests_fail=$((num_of_tests_fail+1))
				echo "FAIL"
			fi
			break
			;;
			tenants)
				echo " "
				echo "**:********************************************************"
				echo " "
				echo "Tenants:"
				echo "------ "
				header=`echo X-Tapis-token:$user_token`
				echo "Test: List tenants"
				RESULT=`curl -o /dev/null -w '%{http_code}' -H "$header" $base_url/v3/tenants 2>/dev/null`
				echo $RESULT
	            num_of_tests=$((num_of_tests+1))
	            if [ $RESULT = '200' ]; then
	            	num_of_tests_pass=$((num_of_tests_pass+1))
	            	echo "PASS"
				else
					num_of_tests_fail=$((num_of_tests_fail+1))
					echo "FAIL"
				fi
				echo""
				echo "Test: Get tenant details"
				RESULT=`curl -o /dev/null -w '%{http_code}' -H "$header" $base_url/v3/tenants/dev 2>/dev/null`
				echo $RESULT
	            num_of_tests=$((num_of_tests+1))
	            if [ $RESULT = '200' ]; then
	            	num_of_tests_pass=$((num_of_tests_pass+1))
	            	echo "PASS"
				else
					num_of_tests_fail=$((num_of_tests_fail+1))
					echo "FAIL"
				fi
				echo""
				echo "Test: Get owners list"
				RESULT=`curl -o /dev/null -w '%{http_code}'  -H "$header" $base_url/v3/tenants/owners 2>/dev/null`
				echo $RESULT
	            num_of_tests=$((num_of_tests+1))
	            if [ $RESULT = '200' ]; then
	            	num_of_tests_pass=$((num_of_tests_pass+1))
	            	echo "PASS"
				else
					num_of_tests_fail=$((num_of_tests_fail+1))
					echo "FAIL"
				fi
				break
				;;
				files)
				echo " "
				echo "**********************************************************"
				echo " "
				echo "Files:"
				echo "------ "
				header=`echo X-Tapis-token:$user_token`
				echo "Test: List Files"
				RESULT=`curl -o /dev/null -w '%{http_code}' -H "$header" $base_url/v3/files/ops/$system/ 2>/dev/null`
				echo $RESULT
	            num_of_tests=$((num_of_tests+1))
	            if [ $RESULT = '200' ]; then
	            	num_of_tests_pass=$((num_of_tests_pass+1))
	            	echo "PASS"
				else
					num_of_tests_fail=$((num_of_tests_fail+1))
					echo "FAIL"
				fi
				echo""
				echo "Test: Files healthcheck"
				RESULT=`curl -o /dev/null -w '%{http_code}' $base_url/v3/files/healthcheck 2>/dev/null`
				echo $RESULT
	            num_of_tests=$((num_of_tests+1))
	            if [ $RESULT = '200' ]; then
	            	num_of_tests_pass=$((num_of_tests_pass+1))
	            	echo "PASS"
				else
					num_of_tests_fail=$((num_of_tests_fail+1))
					echo "FAIL"
				fi
				break
				;;
				meta)
				echo " "
				echo "**********************************************************"
				echo " "
				echo "Meta:"
				echo "------ "
				service_token_generation
				header1=`echo X-Tapis-token:$service_token`
				header2=`echo  X-Tapis-User:streams`
				header3=`echo  X-Tapis-tenant:admin`
				echo "Test: List Collections"
				RESULT=`curl -o /dev/null -w '%{http_code}' -H "$header1" -H "$header2" -H "$header3" $base_url/v3/meta/$db 2>/dev/null`
				echo $RESULT
	            num_of_tests=$((num_of_tests+1))
	            if [ $RESULT = '200' ]; then
	            	num_of_tests_pass=$((num_of_tests_pass+1))
	            	echo "PASS"
				else
					num_of_tests_fail=$((num_of_tests_fail+1))
					echo "FAIL"
				fi
				echo""
				echo "Test: Get metadata for database: $db"
				RESULT=`curl -o /dev/null -w '%{http_code}' -H "$header1" -H "$header2" -H "$header3" $base_url/v3/meta/$db/_meta 2>/dev/null`
				echo $RESULT
	            num_of_tests=$((num_of_tests+1))
	            if [ $RESULT = '200' ]; then
	            	num_of_tests_pass=$((num_of_tests_pass+1))
	            	echo "PASS"
				else
					num_of_tests_fail=$((num_of_tests_fail+1))
					echo "FAIL"
				fi
				echo""
				echo "Test: Healthcheck"
				RESULT=`curl -o /dev/null -w '%{http_code}'  $base_url/v3/meta/healthcheck 2>/dev/null`
				echo $RESULT
	            num_of_tests=$((num_of_tests+1))
	            if [ $RESULT = '200' ]; then
	            	num_of_tests_pass=$((num_of_tests_pass+1))
	            	echo "PASS"
				else
					num_of_tests_fail=$((num_of_tests_fail+1))
					echo "FAIL"
				fi
				break
				;;
				jobs)
				echo " "
				echo "**********************************************************"
				echo " "
				echo "Jobs:"
				echo "------ "
				echo "Test: Healthcheck"
				RESULT=`curl -o /dev/null -w '%{http_code}'  $base_url/v3/jobs/healthcheck 2>/dev/null`
				echo $RESULT
	            num_of_tests=$((num_of_tests+1))
	            if [ $RESULT = '200' ]; then
	            	num_of_tests_pass=$((num_of_tests_pass+1))
	            	echo "PASS"
				else
					num_of_tests_fail=$((num_of_tests_fail+1))
					echo "FAIL"
				fi
				break
				;;
				apps)
				echo " "
				echo "**********************************************************"
				echo " "
				echo "Apps:"
				echo "------ "
				echo "Test: Healthcheck"
				RESULT=`curl -o /dev/null -w '%{http_code}'  $base_url/v3/apps/healthcheck 2>/dev/null`
				echo $RESULT
	            num_of_tests=$((num_of_tests+1))
	            if [ $RESULT = '200' ]; then
	            	num_of_tests_pass=$((num_of_tests_pass+1))
	            	echo "PASS"
				else
					num_of_tests_fail=$((num_of_tests_fail+1))
					echo "FAIL"
				fi
				echo "------ "
				echo "Test: Ready"
				RESULT=`curl -o /dev/null -w '%{http_code}'  $base_url/v3/apps/readycheck 2>/dev/null`
				echo $RESULT
	            num_of_tests=$((num_of_tests+1))
	            if [ $RESULT = '200' ]; then
	            	num_of_tests_pass=$((num_of_tests_pass+1))
	            	echo "PASS"
				else
					num_of_tests_fail=$((num_of_tests_fail+1))
					echo "FAIL"
				fi
			    echo "------ "

				echo "Test: List apps."
				header=`echo X-Tapis-token:$user_token`
				RESULT=`curl -o /dev/null -w '%{http_code}' -H "$header" $base_url/v3/apps 2>/dev/null`
				echo $RESULT
	            num_of_tests=$((num_of_tests+1))
	            if [ $RESULT = '200' ]; then
	            	num_of_tests_pass=$((num_of_tests_pass+1))
	            	echo "PASS"
				else
					num_of_tests_fail=$((num_of_tests_fail+1))
					echo "FAIL"
				fi
				echo "------ "

				echo "Test: Get app details"
				header=`echo X-Tapis-token:$user_token` 
				#echo $header
				RESULT=`curl -o /dev/null -w '%{http_code}' -H "$header" $base_url/v3/apps/$app 2>/dev/null`
				#echo $RESULT
	            num_of_tests=$((num_of_tests+1))
	            if [ $RESULT = '200' ]; then
	            	num_of_tests_pass=$((num_of_tests_pass+1))
	            	echo "PASS"
				else
					num_of_tests_fail=$((num_of_tests_fail+1))
					echo "FAIL"
				fi
				break
				;;
				actors)
				echo " "
				echo "**********************************************************"
				echo " "
				echo "Actors:"
				echo "------ "
				echo "Test:List Actors"
				header=`echo X-Tapis-token:$user_token`
				RESULT=`curl -o /dev/null -w '%{http_code}'  -H "$header" $base_url/v3/actors 2>/dev/null`
				echo $RESULT
	            num_of_tests=$((num_of_tests+1))
	            if [ $RESULT = '200' ]; then
	            	num_of_tests_pass=$((num_of_tests_pass+1))
	            	echo "PASS"
				else
					num_of_tests_fail=$((num_of_tests_fail+1))
					echo "FAIL"
				fi
				echo "Test:Create Actors"
				header=`echo X-Tapis-token:$user_token`
				RESULT=`curl -X POST  -H "Content-type:application/json" --data '{"image":"jstubbs/abaco_test", "name":"Regular smoke test actor"}' -H "$header" $base_url/v3/actors 2>/dev/null`
				#echo $RESULT
	            num_of_tests=$((num_of_tests+1))
	            STATUS=`echo $RESULT | jq -r '.status'` 
	            #echo $STATUS
	            if [ $STATUS = 'success' ]; then
	            	num_of_tests_pass=$((num_of_tests_pass+1))
	            	Actor_id=`echo $RESULT | jq -r '.result.id'` 
	            	echo $Actor_id
	            	echo "PASS"
				else
					num_of_tests_fail=$((num_of_tests_fail+1))
					echo "FAIL"
				fi
				echo "Test:Delete Actors"
				header=`echo X-Tapis-token:$user_token`
				RESULT=`curl -o /dev/null -w '%{http_code}' -X DELETE  -H "$header" $base_url/v3/actors/$Actor_id 2>/dev/null`
				echo $RESULT
	            num_of_tests=$((num_of_tests+1))
	            if [ $RESULT = '200' ]; then
	            	num_of_tests_pass=$((num_of_tests_pass+1))
	            	echo "PASS"
				else
					num_of_tests_fail=$((num_of_tests_fail+1))
					echo "FAIL"
				fi
				break
				;;
				authenticator)
				echo " "
				echo "**********************************************************"
				echo " "
				echo "Authenticator:"
				echo "------ "
				echo "Test: Generate user token for user:  $user"
					payload="{\"username\": \"$user\", \"password\":\"$pass\" , \"grant_type\": \"password\" }"
					RESULT=`curl -H "Content-type: application/json" -d "$payload" $base_url/v3/oauth2/tokens 2>/dev/null`
            		num_of_tests=$((num_of_tests+1))
					user_token=`echo $RESULT | jq -r '.result.access_token.access_token'`
					#echo $user_token
          if [ $user_token = 'null' ]; then
        				echo "User token generation failed for $auth_user in tenant $auth_base"
					      num_of_tests_fail=$((num_of_tests_fail+1))
					else
					    num_of_tests_pass=$((num_of_tests_pass+1))
	            echo "PASS"
	        fi
				break
				;;
		#: If user inputs invalid service name
		*)
			echo "  "
			echo "**********************************************************"
			echo " "
			echo "Please enter a valid service name: streams, sk, meta, tenants, files, systems,authenticator, apps, actors, all"
			break
			;;
		esac
	done

}
#: Parse comand line arguements. $1 -h: HELP  -s, --service : streams, sk, all (To run smoke tests for all services) , -env $2 dev, stg

function parse_args() {

	#: List Services contains names of all services, for which smoke tests will be run when user selects -s all or --service all
	Services=("streams"  "sk" "tenants" "systems" "meta" "files" "jobs"  "actors" "apps" "authenticator")

	#: List of tenants
	Tenants=( "dev")
	
    echo "***** Begin Smoke Tests for Tapis V3  ****************"
	echo " "
	core_service_temp="all"
	tenant_name_temp="dev"
            
	#: Convert tenant names to lower case
	tenant_name=`echo $tenant_name_temp | tr '[A-Z]' '[a-z]'`


	#: Convert service names to lower case, so they match with case ids in switch case
	core_service=`echo $core_service_temp | tr '[A-Z]' '[a-z]'`
		
	load_config $tenant_name, $base_url, $pass, $user, $service_pass, $auth_user, $auth_base, $auth_pass, $admin_base_url  $system  $app

	echo "Test: Generate user token"
	payload="{\"username\": \"$user\", \"password\":\"$pass\" , \"grant_type\": \"password\" }"
	echo $payload
	RESULT=`curl -H "Content-type: application/json" -d "$payload" $base_url/v3/oauth2/tokens 2>/dev/null`
	user_token=`echo $RESULT | jq -r '.result.access_token.access_token'`
	echo $user_token
    if [ $user_token = 'null' ]; then
			echo "User token generation failed for $user in tenant $base_url"
			break
	fi

	echo "####################################################################"
	echo " "
	echo "Running smoke tests for tenant: "$base_url
	echo " "
				#	echo "####################################################################"
	### Run smoke tests for particular service
	
	###: For all services in the Services list run the smoke tests and calculate the run statistics
	for i in "${Services[@]}"
		do
			core_service=$i
			smoke_tests $core_service, $total_core_test, $total_core_pass, $total_core_fail, $flag_tests_fail, $tenant_name, $user_token, $tenant, $auth_user, $auth_base, $auth_pass, $admin_base_url, $app

		done
		core_service="all"
						###: Update the run statsistics to get data from last service run
		total_core_test=$((total_core_test+num_of_tests))
		total_core_pass=$((total_core_pass+num_of_tests_pass))
		total_core_fail=$((total_core_fail+num_of_tests_fail))
        tenants_pass[tenant_counter]=$total_core_pass
        tenants_fail[tenant_counter]=$total_core_fail
        tenants_total[tenant_counter]=$total_core_test
        tenant_counter=$tenant_counter+1
		echo "***************** Summary ***********************"
		echo " "
		echo "Total Tests passed: " $total_core_pass"/"$total_core_test
		echo " "
		echo "Total Tests fail: " $total_core_fail"/"$total_core_test
		echo " "
		echo " *************** End of tests *******************"

		
		echo " Test summary for all tenants: "
		echo " "
		echo -e "Tenant Name : Total tests pass | Total tests run "
		t=0
		for i in ${Tenants[@]}
		do
			echo -e " $i : ${tenants_pass[t]} | ${tenants_total[t]} "
			t=$t+1

		done

}

###: Main function
main() {

	parse_args "$@"
	###: Call to Clean up function has been commented for now
   	#cleanup_temp_files
}


main  "$@" 





