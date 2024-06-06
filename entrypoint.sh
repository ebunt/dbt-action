#!/bin/bash

set -o pipefail

echo "dbt project folder set as: \"${INPUT_DBT_PROJECT_FOLDER}\""
cd ${INPUT_DBT_PROJECT_FOLDER}

export PROFILES_FILE="${DBT_PROFILES_DIR:-.}/profiles.yml"
if [ -e "${PROFILES_FILE}" ]  
then
  if [ -n "${DBT_USER}" ] && [ -n "$DBT_PASSWORD" ]
  then
    echo trying to use user/password
    sed -i "s/_user_/${DBT_USER}/g" $PROFILES_FILE
    sed -i "s/_password_/${DBT_PASSWORD}/g" $PROFILES_FILE
  else
    echo no credentials supplied
  fi
else
  echo "profiles.yml not found"
  exit 1
fi

DBT_ACTION_LOG_FILE=${DBT_ACTION_LOG_FILE:="dbt_console_output.txt"}
DBT_ACTION_LOG_PATH="${INPUT_DBT_PROJECT_FOLDER}/${DBT_ACTION_LOG_FILE}"

echo "DBT_ACTION_LOG_PATH=${DBT_ACTION_LOG_PATH}" >> $GITHUB_ENV
echo "Saving console output in \"${DBT_ACTION_LOG_PATH}\""

$1 2>&1 | tee "${DBT_ACTION_LOG_FILE}"

if [ $? -eq 0 ]
  then
    echo "DBT_RUN_STATE=passed" >> $GITHUB_ENV
    echo "result=passed" >> $GITHUB_OUTPUT
    echo "DBT run OK" >> "${DBT_ACTION_LOG_FILE}"
  else
    echo "DBT_RUN_STATE=failed" >> $GITHUB_ENV
    echo "result=failed" >> $GITHUB_OUTPUT
    echo "DBT run failed" >> "${DBT_ACTION_LOG_FILE}"
    exit 1
fi
