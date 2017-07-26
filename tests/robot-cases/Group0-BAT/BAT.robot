*** Settings ***
Documentation  Harbor BATs
Resource  ../../resources/Util.robot
Suite Setup  Install Harbor to Test Server
Default Tags  BAT

*** Variables ***
${HARBOR_URL}  http://localhost

*** Test Cases ***
Test Case - Create An New User
    Init Chrome Driver
    ${d}=    Get Current Date    result_format=%m%s
    Create An New User  url=${HARBOR_URL}  username=tester${d}  email=tester${d}@vmware.com  realname=harbortest  newPassword=Test1@34  comment=harbortest
    Close Browser

Test Case - Sign With Admin
    Init Chrome Driver
    Sign In Harbor  ${HARBOR_URL}  %{HARBOR_ADMIN}  %{HARBOR_PASSWORD}
    Close Browser

Test Case - Update User Comment
    Init Chrome Driver
    ${d}=    Get Current Date    result_format=%m%s
    Create An New User  url=${HARBOR_URL}  username=tester${d}  email=tester${d}@vmware.com  realname=harbortest  newPassword=Test1@34  comment=harbortest
    Update User Comment  Test12#4
    Logout Harbor

Test Case - Update Password
    Init Chrome Driver
    ${d}=    Get Current Date    result_format=%m%s
    Create An New User  url=${HARBOR_URL}  username=tester${d}  email=tester${d}@vmware.com  realname=harbortest  newPassword=Test1@34  comment=harbortest
    Change Password  Test1@34  Test12#4
    Logout Harbor
    Sign In Harbor  ${HARBOR_URL}  tester${d}  Test12#4
    Close Browser
	
Test Case - Create An New Project
    Init Chrome Driver
    ${d}=    Get Current Date    result_format=%m%s
    Create An New User  url=${HARBOR_URL}  username=tester${d}  email=tester${d}@vmware.com  realname=harbortest  newPassword=Test1@34  comment=harbortest
    Create An New Project  test${d}
    Close Browser

Test Case - User View Projects
    Init Chrome Driver
    ${d}=    Get Current Date    result_format=%m%s
    Create An New User  url=${HARBOR_URL}  username=tester${d}  email=tester${d}@vmware.com  realname=harbortest  newPassword=Test1@34  comment=harbortest
    Create An New Project  test${d}1
    Create An New Project  test${d}2
    Create An New Project  test${d}3
    Switch To Log
	Capture Page Screenshot  UserViewProjects.png
    Wait Until Page Contains  test${d}1
    Wait Until Page Contains  test${d}2
    Wait Until Page Contains  test${d}3
    Close Browser	
	
Test Case - Push Image
    Init Chrome Driver
    ${d}=    Get Current Date    result_format=%m%s
    Create An New User  url=${HARBOR_URL}  username=tester${d}  email=tester${d}@vmware.com  realname=harbortest  newPassword=Test1@34  comment=harbortest
    Create An New Project  test${d}

    ${rc}  ${ip}=  Run And Return Rc And Output  ip addr s eth0 |grep "inet "|awk '{print $2}' |awk -F "/" '{print $1}'
    Log To Console  ${ip}	
	Push image  ${ip}  tester${d}  Test1@34  test${d}  hello-world:latest

    Go Into Project  test${d}
    Wait Until Page Contains  test${d}/hello-world

Test Case - User View Logs
    Init Chrome Driver
    ${d}=   Get Current Date    result_format=%m%s
    ${rc}  ${ip}=  Run And Return Rc And Output  ip addr s eth0|grep "inet "|awk '{print $2}'|awk -F "/" '{print $1}'
    Log to console  ${ip}
			
	Create An New Public Project With New User  url=${HARBOR_URL}  username=tester${d}  email=tester${d}@vmware.com  realname=tester${d}  newPassword=Test1@34  comment=harbor  projectname=project${d}

	Push image  ${ip}  tester${d}  Test1@34  project${d}  busybox:latest
    Pull image  ${ip}  tester${d}  Test1@34  project${d}  busybox:latest
    
	Go Into Project  project${d}
	Delete Repo  project${d}
	
	Go To Project Log
	Advanced Search Should Display
	
	Do Log Advanced Search
    Close Browser
	
Test Case - Manage project publicity
    Init Chrome Driver
    ${d}=    Get Current Date  result_format=%m%s
    ${rc}  ${ip}=    run and return rc and output  ip a s eth0|grep "inet "|awk '{print $2}'|awk -F "/" '{print $1}'
    Log to console  ${ip}

    Create An New User  url=${HARBOR_URL}  username=usera${d}  email=usera${d}@vmware.com  realname=usera${d}  newPassword=Test1@34  comment=harbor
    Logout Harbor
    Create An New User  url=${HARBOR_URL}  username=userb${d}  email=userb${d}@vmware.com  realname=userb${d}  newPassword=Test1@34  comment=harbor
    Logout Harbor

    Sign In Harbor  ${HARBOR_URL}  usera${d}  Test1@34
    Create An New Public Project  project${d}

    Push image  ${ip}  usera${d}  Test1@34  project${d}  hello-world:latest
    Pull image  ${ip}  userb${d}  Test1@34  project${d}  hello-world:latest

    Logout Harbor
    Sign In Harbor  ${HARBOR_URL}  userb${d}  Test1@34
    Project Should Display  project${d}
    Search Private Projects
    Project Should Not Display  project${d}

    Logout Harbor
    Sign In Harbor  ${HARBOR_URL}  usera${d}  Test1@34
    Make Project Private  project${d}

    Logout Harbor
    Sign In Harbor  ${HARBOR_URL}  userb${d}  Test1@34
    Project Should Not Display  project${d}
    Cannot Pull image  ${ip}  userb${d}  Test1@34  project${d}  hello-world:latest

    Logout Harbor
    Sign In Harbor  ${HARBOR_URL}  usera${d}  Test1@34
    Make Project Public  project${d}

    Logout Harbor
    Sign In Harbor  ${HARBOR_URL}  userb${d}  Test1@34
    Project Should Display  project${d}
	Close Browser

Test Case - Edit Project Creation
	# create normal user and login
    Init Chrome Driver
    ${d}=    Get Current Date    result_format=%m%s
    Create An New User  url=${HARBOR_URL}  username=tester${d}  email=tester${d}@vmware.com  realname=harbortest  newPassword=Test1@34  comment=harbortest

	#check project creation
    Page Should Contain Element  xpath=//project//div[@class="option-left"]/button

	#logout and login admin
    Logout Harbor
	Sleep  3
    Sign In Harbor  ${HARBOR_URL}  %{HARBOR_ADMIN}  %{HARBOR_PASSWORD}
	Set Pro Create Admin Only

	#logout and login normal user
    Logout Harbor
	Sign In Harbor  ${HARBOR_URL}  tester${d}  Test1@34
	Page Should Not Contain Element  xpath=//project//div[@class="option-left"]/button

	Logout Harbor
    Sign In Harbor  ${HARBOR_URL}  %{HARBOR_ADMIN}  %{HARBOR_PASSWORD}

    Set Pro Create Every One
    Close browser

Test Case - Edit Self-Registration
	#login as admin
    Init Chrome Driver
    Sign In Harbor  ${HARBOR_URL}  %{HARBOR_ADMIN}  %{HARBOR_PASSWORD}
    Disable Self Reg

	Logout Harbor
    Page Should Not Contain Element  xpath=//a[@class="signup"]
    Sign In Harbor  ${HARBOR_URL}  %{HARBOR_ADMIN}  %{HARBOR_PASSWORD}

	Switch To Configure
    Self Reg Should Be Disabled
    Sleep  1

	#restore setting
    Enable Self Reg
    Close Browser

Test Case - Edit Verify Remote Cert
    Init Chrome Driver
    Sign In Harbor  ${HARBOR_URL}  %{HARBOR_ADMIN}  %{HARBOR_PASSWORD}

    Switch To System Replication
    Check Verify Remote Cert

    Logout Harbor
    Sign In Harbor  ${HARBOR_URL}  %{HARBOR_ADMIN}  %{HARBOR_PASSWORD}

    Switch To System Replication
    Should Verify Remote Cert Be Enabled

    #restore setting
    Check Verify Remote Cert
    Close Browser

Test Case - Edit Email Settings
    Init Chrome Driver
    Sign In Harbor  ${HARBOR_URL}  %{HARBOR_ADMIN}  %{HARBOR_PASSWORD}

	Switch To Email
    Config Email

    Logout Harbor
    Sign In Harbor  ${HARBOR_URL}  %{HARBOR_ADMIN}  %{HARBOR_PASSWORD}

	Switch To Email
    Verify Email

    Close Browser

Test Case - Edit Token Expire
    Init Chrome Driver
    Sign In Harbor  ${HARBOR_URL}  %{HARBOR_ADMIN}  %{HARBOR_PASSWORD}
	Switch To System Settings
	Modify Token Expiration  20
    Logout Harbor

	Sign In Harbor  ${HARBOR_URL}  %{HARBOR_ADMIN}  %{HARBOR_PASSWORD}
	Switch To System Settings
    Token Must Be Match  20

	#reset to default
    Modify Token Expiration  30
    Close Browser

Test Case - Create An Replication Rule New Endpoint
    Init Chrome Driver
    ${d}=  Get current date  result_format=%m%s
    Sign In Harbor  ${HARBOR_URL}  %{HARBOR_ADMIN}  %{HARBOR_PASSWORD}
    Create An New Project  project${d}
    Sleep  3
	Go Into Project  project${d}
    Switch To Replication
    Create An New Rule With New Endpoint  policy_name=test_policy_${d}  policy_description=test_description  destination_name=test_destination_name_${d}  destination_url=test_destination_url_${d}  destination_username=test_destination_username  destination_password=test_destination_password
	Close Browser

Test Case - Assign Sys Admin
    Init Chrome Driver
    ${d}=    Get Current Date    result_format=%m%s
    Create An New User  url=${HARBOR_URL}  username=tester${d}  email=tester${d}@vmware.com  realname=harbortest  newPassword=Test1@34  comment=harbortest
    Logout Harbor
    Sign In Harbor  ${HARBOR_URL}  %{HARBOR_ADMIN}  %{HARBOR_PASSWORD}
    Switch to User Tag
    Assign User Admin  tester${d}
    Logout Harbor
    Sign In Harbor  ${HARBOR_URL}  tester${d}  Test1@34
    Administration Tag Should Display
    Close Browser

Test Case - Ldap Sign in and out
    Switch To LDAP
    Init Chrome Driver
    Sign In Harbor  ${HARBOR_URL}  %{HARBOR_ADMIN}  %{HARBOR_PASSWORD}
    Switch To Configure
    Init LDAP
    Logout Harbor
    Sign In Harbor  ${HARBOR_URL}  user001  user001
    Close Browser

Test Case - Admin Push Signed Image
    Switch To Notary

    ${rc}  ${ip}=  Run And Return Rc And Output  ip addr s eth0 |grep "inet "|awk '{print $2}' |awk -F "/" '{print $1}'
    Log  ${ip}

    ${rc}  ${output}=  Run And Return Rc And Output  docker pull hello-world:latest
    Log To Console  ${output}
		
	Push image  ${ip}  %{HARBOR_ADMIN}  %{HARBOR_PASSWORD}  library  hello-world:latest
	
    ${rc}  ${output}=  Run And Return Rc And Output  ./tests/robot-cases/Group9-Content-trust/notary-push-image.sh
    Log To Console  ${output}
    Should Be Equal As Integers  ${rc}  0

    ${rc}  ${output}=  Run And Return Rc And Output  curl -u admin:Harbor12345 -s --insecure -H "Content-Type: application/json" -X GET "https://${ip}/api/repositories/library/tomcat/signatures"
    Log To Console  ${output}
    Should Be Equal As Integers  ${rc}  0
    #Should Contain  ${output}  sha256

Test Case - Admin Push Un-Signed Image
    ${rc}  ${ip}=  Run And Return Rc And Output  ip addr s eth0 |grep "inet "|awk '{print $2}' |awk -F "/" '{print $1}'
    Log  ${ip}
	
    ${rc}  ${output}=  Run And Return Rc And Output  docker push ${ip}/library/hello-world:latest
    Log To Console  ${output}

#Test Case - Notary Inteceptor
#    ${rc}  ${output}=  Run And Return Rc And Output  ./tests/robot-cases/Group9-Content-trust/notary-pull-image-inteceptor.sh
#    Log To Console  ${output}
#    Should Be Equal As Integers  ${rc}  0
#
#    Down Harbor  with_notary=true
#    ${rc}  ${output}=  Run And Return Rc And Output  echo "PROJECT_CONTENT_TRUST=1\n" >> ./make/common/config/ui/env
#    Log To Console  ${output}
#    Should Be Equal As Integers  ${rc}  0
#    ${rc}  ${output}=  Run And Return Rc And Output  cat ./make/common/config/ui/env
#
#    Log To Console  ${output}
#	Up Harbor  with_notary=true
#    ${rc}  ${output}=  Run And Return Rc And Output  ./tests/robot-cases/Group9-Content-trust/notary-pull-image-inteceptor.sh
#    Log To Console  ${output}
#
#	Down Harbor  with_notary=true
#	${rc}  ${output}=  Run And Return Rc And Output  sed "s/^PROJECT_CONTENT_TRUST=1.*/PROJECT_CONTENT_TRUST=0/g" -i ./make/common/config/ui/env
#   Log To Console  ${output}
#   Should Be Equal As Integers  ${rc}  0
#    ${rc}  ${output}=  Run And Return Rc And Output  cat ./make/common/config/ui/env
#
#	Up Harbor  with_notary=true
#    ${rc}  ${output}=  Run And Return Rc And Output  ./tests/robot-cases/Group9-Content-trust/notary-pull-image-inteceptor.sh
#    Log To Console  ${output}
#    Should Be Equal As Integers  ${rc}  0
