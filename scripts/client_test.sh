#!/usr/bin/env bash

JOB_TYPE=$1
PS_NUM=$2
WORKER_NUM=$3

if [[ "$JOB_TYPE" == "train" ]]; then
    elasticdl train \
      --image_base=elasticdl:ci \
      --model_zoo=model_zoo \
      --model_def=deepfm_functional_api.deepfm_functional_api.custom_model \
      --training_data=/data/frappe/train \
      --validation_data=/data/frappe/test \
      --num_epochs=1 \
      --master_resource_request="cpu=0.2,memory=1024Mi" \
      --master_resource_limit="cpu=1,memory=2048Mi" \
      --worker_resource_request="cpu=0.4,memory=2048Mi" \
      --worker_resource_limit="cpu=1,memory=3072Mi" \
      --ps_resource_request="cpu=0.2,memory=1024Mi" \
      --ps_resource_limit="cpu=1,memory=2048Mi" \
      --minibatch_size=64 \
      --num_minibatches_per_task=2 \
      --num_workers=$WORKER_NUM \
      --num_ps_pods=$PS_NUM \
      --checkpoint_steps=500 \
      --evaluation_steps=500 \
      --tensorboard_log_dir=/tmp/tensorboard-log \
      --grads_to_wait=1 \
      --use_async=True \
      --job_name=test-train \
      --log_level=INFO \
      --image_pull_policy=Never \
      --output=/saved_model/model_output \
      --volume="host_path=${PWD},mount_path=/saved_model"
elif [[ "$JOB_TYPE" == "evaluate" ]]; then
    elasticdl evaluate \
      --image_base=elasticdl:ci \
      --model_zoo=model_zoo \
      --model_def=mnist_functional_api.mnist_functional_api.custom_model \
      --checkpoint_filename_for_init=elasticdl/python/tests/testdata/mnist_functional_api_model_v110.chkpt \
      --validation_data=/data/mnist/test \
      --num_epochs=1 \
      --master_resource_request="cpu=0.3,memory=1024Mi" \
      --master_resource_limit="cpu=1,memory=2048Mi" \
      --worker_resource_request="cpu=0.4,memory=2048Mi" \
      --worker_resource_limit="cpu=1,memory=3072Mi" \
      --ps_resource_request="cpu=0.2,memory=1024Mi" \
      --ps_resource_limit="cpu=1,memory=2048Mi" \
      --minibatch_size=64 \
      --num_minibatches_per_task=2 \
      --num_workers=$WORKER_NUM \
      --num_ps_pods=$PS_NUM \
      --evaluation_steps=15 \
      --tensorboard_log_dir=/tmp/tensorboard-log \
      --job_name=test-evaluate \
      --log_level=INFO \
      --image_pull_policy=Never
elif [[ "$JOB_TYPE" == "predict" ]]; then
    elasticdl predict \
      --image_base=elasticdl:ci \
      --model_zoo=model_zoo \
      --model_def=mnist_functional_api.mnist_functional_api.custom_model \
      --checkpoint_filename_for_init=elasticdl/python/tests/testdata/mnist_functional_api_model_v110.chkpt \
      --prediction_data=/data/mnist/test \
      --master_resource_request="cpu=0.2,memory=1024Mi" \
      --master_resource_limit="cpu=1,memory=2048Mi" \
      --worker_resource_request="cpu=0.4,memory=2048Mi" \
      --worker_resource_limit="cpu=1,memory=3072Mi" \
      --ps_resource_request="cpu=0.2,memory=1024Mi" \
      --ps_resource_limit="cpu=1,memory=2048Mi" \
      --minibatch_size=64 \
      --num_minibatches_per_task=2 \
      --num_workers=$WORKER_NUM \
      --num_ps_pods=$PS_NUM \
      --job_name=test-predict \
      --log_level=INFO \
      --image_pull_policy=Never
elif [[ "$JOB_TYPE" == "odps" ]]; then
    elasticdl train \
      --image_base=elasticdl:ci \
      --model_zoo=model_zoo \
      --model_def=odps_iris_dnn_model.odps_iris_dnn_model.custom_model \
      --training_data=$ODPS_TABLE_NAME \
      --data_reader_params='columns=["sepal_length", "sepal_width", "petal_length", "petal_width", "class"]' \
      --envs="ODPS_PROJECT_NAME=$ODPS_PROJECT_NAME,ODPS_ACCESS_ID=$ODPS_ACCESS_ID,ODPS_ACCESS_KEY=$ODPS_ACCESS_KEY,ODPS_ENDPOINT=" \
      --num_epochs=2 \
      --master_resource_request="cpu=0.2,memory=1024Mi" \
      --master_resource_limit="cpu=1,memory=2048Mi" \
      --worker_resource_request="cpu=0.4,memory=2048Mi" \
      --worker_resource_limit="cpu=1,memory=3072Mi" \
      --ps_resource_request="cpu=0.2,memory=1024Mi" \
      --ps_resource_limit="cpu=1,memory=2048Mi" \
      --minibatch_size=64 \
      --num_minibatches_per_task=2 \
      --num_workers=$WORKER_NUM \
      --num_ps_pods=$PS_NUM \
      --checkpoint_steps=10 \
      --grads_to_wait=2 \
      --job_name=test-odps \
      --log_level=INFO \
      --image_pull_policy=Never \
      --output=model_output
else
    echo "Unsupported job type specified: $JOB_TYPE"
    exit 1
fi
