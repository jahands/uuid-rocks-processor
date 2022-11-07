import time
import os

from google.cloud import bigquery_datatransfer_v1
from google.oauth2 import service_account
from google.protobuf.timestamp_pb2 import Timestamp

credentials = service_account.Credentials.from_service_account_file(
    '/tmp/gcp-keyfile.json')

transfer_client = bigquery_datatransfer_v1.DataTransferServiceClient(
    credentials=credentials)

now = time.time()
seconds = int(now)
nanos = int((now - seconds) * 10**9)
config_name = os.environ['GCP_TRANSFER_CONFIG']
start_time = Timestamp(seconds=seconds - 10, nanos=nanos)
request = bigquery_datatransfer_v1.types.StartManualTransferRunsRequest({
    "parent":
    config_name,
    "requested_run_time":
    start_time
})
response = transfer_client.start_manual_transfer_runs(request, timeout=360)
