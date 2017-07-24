#!/bin/bash

# fail if any commands fails
set -e
# debug log
if [ "${debug}" == "true" ] ; then
    set -x
fi

PYTEST_OPT=""

REQUIREMENTS_PATH=requirements.txt

PYTEST_OPT+=" --ignore=bin --ignore=lib --ignore=include --ignore=selenium"

if [ -n "${junit_file_path}" ] ; then
    PYTEST_OPT+=" --junit-xml=${junit_file_path}"
    envman add --key PYTEST_JUNIT_PATH --value ${junit_file_path}
fi

if [ -n "${pytest_options}" ] ; then
    PYTEST_OPT+=" ${pytest_options}"
fi

#PYTEST_OPT+=" --collect-only"

if [ -n "${files_and_dirs}" ] ; then
    PYTEST_OPT+=" ${files_and_dirs}"
fi

if [ -n "${requirements_path}" ] ; then
    REQUIREMENTS_PATH="${requirements_path}"
fi

if [ "${virtualenv}" == "true" ] ; then
    echo "Before virtualenv"
    pip3 install virtualenv
    echo "After virtualenv"

    virtualenv ve
    echo "After virtualenv ."
    source ./ve/bin/activate
    echo "After source ./bin/activate"
    echo "Before install requirementsv
    pip3 install -r ${REQUIREMENTS_PATH}
    echo "After install requirementsv
fi

if [ "${appium_enabled}" == "true" ] ; then
    APPIUM_PORT="${appium_port}"
    APPIUM_LOG_PATH="${appium_log_path}"

    if [ "${debug}" == "true" ] ; then
        #brew list node > /dev/null || brew install node
        node -v
        #brew list npm > /dev/null || brew install npm
        npm -v

        npm install -g appium-doctor
        appium-doctor
    fi

    # fixes: npm ERR! Cannot read property 'find' of undefined
    npm cache verify

    # install and start appium
    npm install -g appium@1.6.5

    echo "Starting Appium port: ${APPIUM_PORT}, log: ${APPIUM_LOG_PATH}"
    appium --port ${APPIUM_PORT} --log ${APPIUM_LOG_PATH} --log-level debug &
    APPIUM_PID=$!
    #envman add --key APPIUM_PID --value ${APPIUM_PID}
    #trap "kill ${APPIUM_PID}" EXIT
    # TODO: wait till started
    sleep 5
fi

pytest ${PYTEST_OPT}

if [ "${APPIUM_PID}" ] ; then
    echo "Stopping Appium PID: ${APPIUM_PID}"
    kill ${APPIUM_PID}
fi
