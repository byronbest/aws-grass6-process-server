#!/usr/bin/python

import json
import subprocess
import urllib

queue_name = "scdt-ltpt-line-tiles-request"
cmd = "aws sqs get-queue-url --queue-name="+queue_name
que = subprocess.Popen(cmd,stdout=subprocess.PIPE,shell=True).communicate()[0]
queue = json.loads(que)
queue = queue["QueueUrl"]

cmd = "aws sqs receive-message --queue-url="+queue
done = "aws sqs delete-message --queue-url="+queue+" --receipt-handle="

if queue:
	try_receive_message = True
	while try_receive_message:
		mes = subprocess.Popen(cmd,stdout=subprocess.PIPE,shell=True).communicate()[0]
		if not(mes):
			break
		messages = json.loads(mes)
		for message in messages['Messages']:
			body = urllib.unquote(message['Body']).replace('+',' ')
			rcpt = message['ReceiptHandle']
			print body
                        subprocess.call(done+rcpt,shell=True)

