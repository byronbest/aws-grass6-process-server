#!/usr/bin/python

import os
import os.path
import json
import subprocess
import urllib
import sys
import sh

if len(sys.argv) > 1:
	queue_name = sys.argv[1]
job='RUN1'
if len(sys.argv) > 2:
	job = sys.argv[2]

dir=os.path.join(os.environ["HOME"],job)

if 'STATUSNOTE' not in os.environ:
	print 'missing env STATUSNOTE'
	os._exit(1)


def report(message):
	body = urllib.quote(message.replace('\n',' ').replace('\r','').encode("utf-8"))
	note = "aws sns publish --topic '"+os.environ['STATUSNOTE']+"' --message '"+body+"'"
	subprocess.call(note,shell=True)

if not queue_name:
	report('missing queue_name cannot start')
	os._exit(1)

try:
	if not os.path.exists(dir):
		os.makedirs(dir)
except:
	report('cannot create directory '+dir)
	os._exit(1)

def num (s):
	try:
		return int(s)
	except exceptions.ValueError:
		return int(float(s))

maxfails=0
try:
	if 'MAXFAILS' in os.environ:
		maxfails += num(os.environ['MAXFAILS'])
except:
	pass

try:
	with open('maxfails') as file:
		maxfails = num(file.read().replace('\n',''))
except:
	pass

env = 'export JOBHOME='+job+' ; '
cmd = "aws sqs get-queue-url --queue-name '"+queue_name+"'"
que = subprocess.Popen(cmd,stdout=subprocess.PIPE,shell=True).communicate()[0]
queue = json.loads(que)
queue = queue['QueueUrl']

cmd = "aws sqs receive-message --queue-url '"+queue+"'"
done = "aws sqs delete-message --queue-url '"+queue+"' --receipt-handle "

if queue:
	report(env+queue)
	failed_receive_message = 0
	while maxfails == 0 or ( maxfails > 0 and failed_receive_message < maxfails ):
		if maxfails > 0:
			failed_receive_message += 1
		mes = subprocess.Popen(cmd,stdout=subprocess.PIPE,shell=True).communicate()[0]
		if not mes:
			continue
		messages = json.loads(mes)
		for message in messages['Messages']:
			body = urllib.unquote_plus(message['Body']).replace('\n',' ').replace('\r','')
			rcpt = "'"+message['ReceiptHandle']+"'"
			try:
				sh.sh('-c',env+body,_tty_in=True,_out=job+'/out.txt',_err=job+'/err.txt')
				subprocess.call(done+rcpt,shell=True)
				failed_receive_message = 0
			except Exception as e:
				report(str(e) + ': cannot service '+body)
		if maxfails < 0:
			break
	if failed_receive_message > 0:
		report('giving up... nothing received after '+str(failed_receive_message)+' trys')
