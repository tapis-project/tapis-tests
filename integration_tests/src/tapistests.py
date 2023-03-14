import requests
import json
import os
import timeit
import datetime
from random import randint
import random
import time
from tapipy.tapis import Tapis
import pytest
import logging
import time
import zipfile
import io

# logging.basicConfig(level=logging.DEBUG)
# mylogger = logging.getLogger()

tenant = 'dev'
# ensure project_id is unique each time we execute the notebook to ensure no collisions
time_stamp = str(datetime.datetime.today().isoformat()).replace(':', '_')
time_stamp = time_stamp.replace('.', '')
project_id = 'wq_demo_tapis_proj1' + time_stamp
site_id = 'wq_demo_site'
instrument_id = 'Ohio_River_Robert_C_Byrd_Locks' + time_stamp
channel_id = 'demo_wq_channel' + time_stamp
template_id = 'demo_channel_template'
new_id = "tapisv3-storage" + time_stamp
new_root_dir = "/home/testuser2/" + time_stamp
username = '<Enter Username>'
password = '<Enter Password>'
job_uuid =''
username2 = '<Enter another Username>'
new_appid="tapisv3-app"+ time_stamp
# Assign pod name to use.
pod_id = "demopod"

@pytest.fixture
def client():
    base_url = '<Enter Base url>'
    username =  username
    # account_type = getattr(conf, 'account_type', 'user')
    # tenant_id = getattr(conf, 'tenant_id', 'dev')
    # service_password = getattr(conf, 'service_password', None)
    password = password
    t = Tapis(base_url=base_url,
              username=username,
              password=password,
              spec_dir='home/tapis', download_latest_specs=True)
    t.get_tokens()
    print(t)
    return t



# -----------------
# tenants API tests -
# -----------------

def test_tenants_list_tenants(client):
    tenants = client.tenants.list_tenants()
    for t in tenants:
        assert hasattr(t, 'base_url')
        assert hasattr(t, 'tenant_id')
        assert hasattr(t, 'public_key')
        assert hasattr(t, 'token_service')
        assert hasattr(t, 'security_kernel')


def test_tenants_get_tenant_by_id(client):
    t = client.tenants.get_tenant(tenant_id='dev')
    assert t.base_url == 'https://dev.develop.tapis.io'
    assert t.tenant_id == 'dev'
    assert t.public_key.startswith('-----BEGIN PUBLIC KEY-----')
    assert t.token_service == 'https://dev.develop.tapis.io/v3/tokens'
    assert t.security_kernel == 'https://dev.develop.tapis.io/v3/security'


def test_tenants_list_owners(client):
    owners = client.tenants.list_owners()
    for o in owners:
        assert hasattr(o, 'create_time')
        assert hasattr(o, 'email')
        assert hasattr(o, 'last_update_time')
        assert hasattr(o, 'name')


def test_tenants_get_owner(client):
    owner = client.tenants.get_owner(email='CICSupport@tacc.utexas.edu')
    assert owner.email == 'CICSupport@tacc.utexas.edu'
    assert owner.name == 'CIC Support'


# ---------------------
# Streams tests -
# ---------------------

def test_streams_list_projects(client):
    result = client.streams.list_projects()
    assert 'active' in str(result)


def test_streams_create_project(client):
    result = client.streams.create_project(project_name=project_id, description='project for integration tests',
                                           owner=username, pi=username, funding_resource='tapis',
                                           project_url='test.tacc.utexas.edu',
                                           active=True)
    assert hasattr(result, 'active')
    assert hasattr(result, 'project_id')


def test_streams_get_project(client):
    result = client.streams.get_project(project_id=project_id)
    assert hasattr(result, 'active')
    assert hasattr(result, 'project_id')


def test_streams_create_site(client):
    result = client.streams.create_site(project_id=project_id, request_body=[{"site_name":site_id, "site_id":site_id,
                                        "latitude":50, "longitude":10, "elevation":2, "description":"test_site"}])
    assert 'chords_id' in str(result)
    assert 'created_at' in str(result)


def test_streams_get_sites(client):
    result = client.streams.get_site(project_id=project_id, site_id=site_id)
    assert hasattr(result, 'chords_id')
    assert hasattr(result, 'created_at')


def test_streams_create_instrument(client):
    result = client.streams.create_instrument(project_id=project_id, site_id=site_id, request_body=[{"topic_category_id":"2", 
                                              "inst_name":instrument_id, "inst_description":"demo instrument",
                                              "inst_id":instrument_id}])

    assert 'inst_description' in str(result)
    assert 'inst_id' in str(result)

def test_streams_get_instruments(client):
    result = client.streams.get_instrument(project_id=project_id, site_id=site_id, inst_id=instrument_id)
    assert hasattr(result, 'chords_id')
    assert hasattr(result, 'created_at')


def test_streams_create_variable(client):
    result = client.streams.create_variable(project_id=project_id, site_id=site_id, inst_id=instrument_id,request_body=[{"topic_category_id":"2",
                                             "var_name":"temperature", "shortname":"temp", "var_id":"temp"}])
    assert 'var_id' in str(result)
    assert 'var_name' in str(result)

def test_streams_list_roles(client):
    result = client.streams.list_roles(resource_id=project_id, user='testuser2',resource_type='project')
    assert 'admin' in str(result)

def test_streams_grant_role(client):
    result = client.streams.grant_role(resource_id=project_id, user='testuser4',resource_type='project',role_name='manager')
    assert 'manager' in str(result)

def test_streams_revoke_role(client):
   result= client.streams.revoke_role(resource_id=project_id, user='testuser4', resource_type='project',role_name='manager')
   assert 'deleted' in str(result)
   
def test_streams_delete_variable(client):
    result = client.streams.delete_variable(project_id=project_id, site_id=site_id, inst_id=instrument_id, var_id='temp')
    assert 'var_id' in str(result)
    assert 'inst_chords_id' in str(result)


def test_streams_delete_instruments(client):
    result = client.streams.delete_instrument(project_id=project_id, site_id=site_id, inst_id=instrument_id)

def test_streams_delete_site(client):
    result = client.streams.delete_site(project_id=project_id, site_id=site_id)

def test_streams_delete_project(client):
    result = client.streams.delete_project(project_id=project_id)
    assert 'tapis_deleted' in str(result)
    assert 'project_id' in str(result)

# ---------------------
# Systems tests -
# ---------------------
def test_systems_get_Systems(client):
    result = client.systems.getSystems()
    assert 'id' in str(result)


def test_systems_get_System_details(client):
    result = client.systems.getSystem(systemId='tapisv3-storage')
    assert 'tapisv3-storage' in str(result)
    assert 'owner' in str(result)


def test_files_make_root_dir(client):
    result = client.files.mkdir(systemId='tapisv3-storage', path=time_stamp)
    assert 'success' in str(result)


def test_systems_get_System_details(client):
    result = client.systems.getSystem(systemId='tapisv3-storage')
    assert hasattr(result, 'effectiveUserId')


# Create System
def test_create_system(client):
    System_file = './storageSystem.json'
    try:
        with open(System_file, 'r') as f:
            systemDef = json.load(f)
    except:
        printer("unable to open file")
    systemDef.update({"id": new_id})
    systemDef.update({"rootDir": new_root_dir})
    result1 = client.systems.createSystem(**systemDef)
    assert 'url' in str(result1)


# Retrieve details for systems
def test_systems_get_System_details2(client):
    result = client.systems.getSystem(systemId=new_id)
    assert new_id in str(result)
    assert 'owner' in str(result)


# Search systems by name
def test_systems_get_System_search_name(client):
    result = client.systems.getSystems(search='id.like.tapis*')
    assert 'tapis' in str(result)


# Sort systems DSC
def test_systems_get_System_sort_dsc(client):
    result = client.systems.getSystems(sortBy='id(Desc)')
    assert 'id' in str(result)


# Compute Total Systems
def test_systems_get_System_compute_total(client):
    result = client.systems.getSystems(computeTotal=True)
    assert 'id' in str(result)

# Get system permissions
def test_systems_get_System_permissions_user(client):
    result = client.systems.getUserPerms(systemId=new_id, userName=username)
    assert 'names' in str(result)


# Grant system permissions to different user
def test_systems_grant_System_permissions_user(client):
    result = client.systems.grantUserPerms(systemId=new_id, userName=username2, permissions=['READ', 'MODIFY'])
    assert 'SYSAPI_PERMS_GRANTED' in str(result)


# Revoke system permissions of different user
def test_systems_revoke_System_permissions_user(client):
    result = client.systems.revokeUserPerms(systemId=new_id, userName=username2, permissions=['READ', 'MODIFY'])
    assert 'MODIFY' in str(result)


# Check if all permissions have been revoked
def test_systems_get_System_permissions_user2(client):
    result = client.systems.getUserPerms(systemId=new_id, userName=username2)
    assert result.names == []


def test_systems_readyCheck(client):
    result = client.systems.readyCheck()
    assert 'Ready' in str(result)


def test_systems_healthCheck(client):
    result = client.systems.healthCheck()
    assert 'Health' in str(result)


# ---------------------
# Files tests -
# ---------------------
# Files healthchceck
def test_files_healthCheck(client):
    result = client.files.healthCheck()
    assert 'Count' in str(result)


# Upload file
#def test_files_upload(client):
#    client.upload(source_file_path='sample.txt', system_id=new_id, dest_file_path='/sample.txt')
#    result = client.files.getContents(systemId=new_id, path='/sample.txt')
 #   assert 'test' in str(result)


# List files
def test_files_list_files(client):
    result = client.files.listFiles(systemId='tapisv3-exec2-test', path='/integration_tests')
    for p in result:
        assert hasattr(p, 'lastModified')
        assert hasattr(p, 'path')


# Get files content
def test_files_get_file_contents(client):
    result = client.files.getContents(systemId='tapisv3-exec2-test', path='/integration_tests/test.out')
    assert 'test' in str(result)

# Delete file
#def test_files_delete(client):
 #   result = client.files.delete(systemId=new_id, path='/sample.txt')
 #   assert 'ok' in str(result)


def test_files_make_filestest_dir(client):
    result = client.files.mkdir(systemId='tapisv3-exec2-test', path='/filetest')
    assert 'success' in str(result)


# Move file
def test_files_move(client):
    result = client.files.moveCopy(systemId='tapisv3-exec2-test', path='/integration_tests/test.out',
                                         newPath='/filetest/test.out',
                                         operation='MOVE')
    assert 'success' in str(result)
    result = client.files.getContents(systemId=new_id, path='/filetest/test.out')
    assert 'test' in str(result)


# Copy File
def test_files_copy(client):
    result = client.files.moveCopy(systemId='tapisv3-exec2-test', path='/filetest/test.out',
                                         newPath='/integration_tests/test.out',
                                         operation='COPY')
    assert 'success' in str(result)
    result = client.files.getContents(systemId='tapisv3-exec2-test', path='/integration_tests/test.out')
    assert 'test' in str(result)


# Create and get transfer task
def test_files_create_get_TransferTask(client):
    destination_system = "tapis://" + new_id + "/"
    result = client.files.createTransferTask(elements=[
        {"sourceURI": "tapis://tapisv3-exec2-test/filetest/test.out", "destinationURI": destination_system}])
    assert 'status: ACCEPTED' in str(result)

    uuid = result.uuid
    result = client.files.getTransferTaskDetails(transferTaskId=uuid)
    assert 'id' in str(result)


#def test_cleanup_files_systems(client):
 #   result = client.files.delete(systemId='tapisv3-storage', path=time_stamp)
 #   assert 'success' in str(result)
    #result = client.systems.deleteSystem(systemId=new_id, confirm=True)
    #assert 'url' in str(result)

# ---------------------
# Postits tests 
# ---------------------
def test_postits_createPostIt_redeem(client):
    result = client.files.createPostIt(systemId='tapisv3-exec2-test',path='/integration_tests/test.out',allowedUses=2)
    assert 'allowedUses' in str(result)
    assert 'created' in str(result)
    # assert len(result) == 0
    postitId = result[0].id
    client.files.redeemPostIt(postitId=postitId)
    assert 'This' in str(result)

def test_postits_list_postits(client):
    result = client.files.listPostIts()
    assert 'allowedUses' in str(result)
    assert 'expiration' in str(result)
    
    # assert len(result) == 0

def test_postits_getPostIt(client):
    result_list = client.files.listPostIts()
    postitId = result_list[0].id
    result = client.files.getPostIt(postitId=postitId)
    assert 'allowedUses' in str(result)
    assert 'created' in str(result)
    result = client.files.deletePostIt(postitId=postitId)
    assert 'changes' in str(result)

# ---------------------
# Actors tests 
# ---------------------
def test_actors_list_actors(client):
    result = client.actors.list_actors()
    assert 'status' in str(result)
    assert 'name' in str(result)
    # assert len(result) == 0

# ---------------------
# Apps tests
# ---------------------
# Retrieve apps list
def test_apps_retieve_apps(client):
    result = client.apps.getApps()
    assert 'id' in str(result)
    assert 'owner' in str(result)


# Create app
def test_apps_create_app(client):
    app_file = './app.json'
    with open('app.json', 'r') as f:
        appDef = json.load(f)
        appDef.update({"id": new_appid})
        appDef["jobAttributes"].update({"execSystemId": new_id})
    result = client.apps.createAppVersion(**appDef)
    assert new_appid in str(result)



# Search app list query parameters limit
def test_apps_search_list_query_limit(client):
    result=client.apps.searchAppsQueryParameters(limit=2)
    assert (len(result))==2

 
# search app list query parameters select attributes id
def test_apps_search_list_query_select_attributes_id(client):
    result=client.apps.searchAppsQueryParameters(select=id)
    assert 'id' in str(result)
    assert 'owner' not in str(result)

# Retrieve latest version of an app
def test_apps_latest_version(client):
    result=client.apps.getAppLatestVersion(appId=new_appid)
    assert 'version' in str(result)
    assert '0.1' in str(result)

# Retrieve app details for a specific version
def test_apps_get_details_for_version(client):
    result=client.apps.getApp(appId=new_appid, appVersion='0.1')
    assert new_appid in str(result)


# Update app
def test_apps_update_app_description(client):
    result=client.apps.patchApp(appId=new_appid, appVersion='0.1', description="app description modified")
    assert 'url' in str(result)
    result=client.apps.getApp(appId=new_appid, appVersion='0.1')
    assert 'modified' in str(result)

# Check if app is enabled
def test_apps_check_enabled(client):
    result=client.apps.isEnabled(appId=new_appid)
    assert 'True' in str(result)

# Disable app
def test_apps_disable_app(client):
    result= client.apps.disableApp(appId=new_appid)
    assert '1' in str(result)

# Enable app
def test_apps_enable_app_for_use(client):
    result=client.apps.enableApp(appId=new_appid)
    assert '1' in str(result)

# Delete app
def test_apps_delete(client):
    result=client.apps.deleteApp(appId=new_appid)
    assert '1' in str(result)
    
# Undelete operation id not found


# Healthcheck
def test_apps_healthcheck(client):
    result=client.apps.healthCheck()
    assert 'Count' in str(result)

# Ready check
def test_apps_readycheck(client):
    result=client.apps.readyCheck()
    assert 'Count' in str(result)


# ---------------------
# Jobs tests
# ---------------------
def test_submit_job(client):
    result = client.jobs.submitJob(name='Test_app', appId='test_app', appVersion='0.0.1',
                                   parameterSet={"envVariables": [{"key": "JOBS_PARMS", "value": "15"}],
                                                 "archiveFilter": {"includes": ["Sleep*"], "includeLaunchFiles": True}},
                                   archiveSystemId='<Enter archive system')
    assert 'uuid' in str(result)
    assert 'PENDING' in str(result)
    job_uuid = result.uuid
    result = client.jobs.getJob(jobUuid=job_uuid)
    assert job_uuid == result.uuid
    time.sleep(100)
    status = client.jobs.getJobStatus(jobUuid=job_uuid)
    assert 'status' in str(status)
    history = client.jobs.getJobHistory(jobUuid=job_uuid)
    assert 'newJobStatus' in str(history)
    assert 'created' in str(history)
    output_list=client.jobs.getJobOutputList(jobUuid=job_uuid, outputPath='/')
    assert 'tapisjob.sh' in str(output_list)
    assert 'nativePermissions' in str(output_list)
    result = client.jobs.getJobOutputDownload(jobUuid=job_uuid,
                                                        outputPath='/')
    zf = zipfile.ZipFile(io.BytesIO(result), "r")
    fileslist= zf.filelist
    assert 'tapisjob.sh' in str(fileslist)
    assert 'compress_size' in str(fileslist)
    assert 'ZipInfo' in str(fileslist)
        

def test_jobs_healthcheck(client):
    result = client.jobs.checkHealth()
    assert 'checkNum' in str(result)

def test_jobs_say_hello(client):
    result = client.jobs.sayHello()
    assert 'Hello' in str(result)


def test_jobs_ready(client):
    result = client.jobs.ready()
    assert 'databaseAccess: True' in str(result)
    assert 'queueAccess: True' in str(result)
    assert 'tenantsAccess: True' in str(result)


# ---------------------
# Notifications tests -
# ---------------------

# ---------------------
# Pods tests -
# ---------------------
def test_get_pods(client):
    result = client.pods.get_pods()

def test_create_pods(client):
    result = client.pods.create_pod(pod_id=pod_id, pod_template="neo4j")
    assert 'url' in str(result)
    assert 'demopod' in str(result)

def test_get_pods_withid(client):
    result = client.pods.get_pod(pod_id='demopod')
    assert 'demopod' in str(result)
    assert 'neo4j' in str(result)

def test_get_pod_permissions(client):
    result = client.pods.get_pod_permissions(pod_id=pod_id)
    assert 'permissions:' in str(result)

def test_set_pod_permissions(client):
    result = client.pods.set_pod_permission(pod_id=pod_id, user='testuser', level='ADMIN')
    assert 'permissions:' in str(result)
    assert 'testuser:ADMIN' in str(result)

def test_get_pod_permissions(client):
    result = client.pods.get_pod_permissions(pod_id=pod_id, user='testuser', level='ADMIN')
    assert 'testuser:ADMIN' in str(result)

def test_get_pod_logs(client):
    result = client.pods.get_pod_logs(pod_id=pod_id)
    assert 'logs' in str(result)

def test_delete_pods(client):
    result = client.pods.delete_pod(pod_id=pod_id, pod_template="neo4j")
    assert 'message' in str(result)



# ---------------------
# Authenticator tests -
# ---------------------
def test_authenticator_hello(client):
    result = client.authenticator.hello()
    assert 'Hello' in str(result)

def test_authenticator_ready(client):
    result = client.authenticator.ready()
    assert 'ready' in str(result)

def test_authenticator_list_clients(client):
    result= client.authenticator.list_clients()


# ---------------------
# Tokens tests -
# ---------------------
def test_system_removeCredentials(client):
    result = client.systems.removeUserCredential(systemId=new_id,userName='testuser2')
    

def test_system_delete(client):
    result = client.systems.deleteSystem(systemId=new_id)


# ---------------------
# PgREST tests -
# ---------------------


