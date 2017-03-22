#
#
# Purpose: check status of WAS message listener ports
#
#
import os
import sys
import string
import smtplib


MSGLISTFILE=""
LISTENER_ERR_FILE=""
CELL="gotsvl1035Cell"
SENDMAIL="/usr/sbin/sendmail"
FROM="wasadm01@gotsvl3010.volvocars.biz"
#TO=["wasopvcc@volvocars.com","CRMSUPP@volvocars.com"]
TO=["wasopvcc@volvocars.com"]
SUBJECT=""
DROPZONE_ROOT="/proj/deploy/"

def create_list_of_msglisteners(server,node):	
	SERVER=server
	print "List of listeners will be generated to ",MSGLISTFILE
	fp=open(MSGLISTFILE,"w")
	listeners=AdminControl.queryNames('type=ListenerPort,cell=%s,node=%s,process=%s,*' % (CELL,NODE,SERVER))

	for listener in listeners.splitlines():
		fp.write(listener)
		fp.write('\n')
	fp.close()

def send_email():
	if os.path.getsize(LISTENER_ERR_FILE) > 0:
		##Send email with contents of file.
		msg = ""
		mesg = []
		SUBJECT = "STATUS OF MESSAGE LISTENERS FOR %s ON %s" % (string.upper(sys.argv[0]),string.upper(NODE))

		tp=open(LISTENER_ERR_FILE)
		for line in tp.readlines():
			#print "Line:",line
			msg += string.upper(line) + " "
		tp.close()


		message= """\
		From: %s
		To: %s
		Subject: %s

		%s
		""" % (FROM, "; ".join(TO), SUBJECT,msg)

		s = smtplib.SMTP('localhost')
		s.sendmail(FROM,TO,message)
		s.quit()
		os.remove(LISTENER_ERR_FILE)

def query_listener_ports(msgport):
	status=AdminControl.getAttribute(msgport.strip(),'started')
	return status

def restart_listener_ports(msgport):
	try:
		AdminControl.invoke(msgport.strip(), 'stop')
		AdminControl.invoke(msgport.strip(), 'start')
	except:
		print "Restart failed for ",msgport
##
## Start processing the listeners of the application

if (len(sys.argv) == 2):
	MSGLISTFILE=DROPZONE_ROOT + sys.argv[0] + "/" + sys.argv[0] + "_msglisteners.txt"
	if not os.path.exists((DROPZONE_ROOT+sys.argv[0])):
		MSGLISTFILE=DROPZONE_ROOT + sys.argv[0][:-1] + "/" + sys.argv[0] + "_msglisteners.txt"
	NODE=sys.argv[1]
	print "File:", MSGLISTFILE
else:
	#print sys.argv[0]
	print "\n\nScript requires the application name and node to execute"
	print "Usage: wsadmin -lang jython -f msg_listener_chk.py <<appserver>> <<node>>\n\n"
	sys.exit()

if os.path.exists(MSGLISTFILE) and os.path.getsize(MSGLISTFILE) > 0:
	try:
		LISTENER_ERR_FILE=DROPZONE_ROOT + sys.argv[0] + "/" + sys.argv[0] + "_error_listeners.txt"

		if not os.path.exists((DROPZONE_ROOT+sys.argv[0])):
			LISTENER_ERR_FILE=DROPZONE_ROOT + sys.argv[0][:-1] + "/" + sys.argv[0] + "_error_listeners.txt"

		ep=open(LISTENER_ERR_FILE,"a+")
		fp = open(MSGLISTFILE)
		count=1
		for msgport in fp.readlines():
			listener=msgport.split('=')[1].split(',')[0]
			#print "Message Listener: ",listener
			status=AdminControl.getAttribute(msgport.strip(),'started')
			
			if status == 'false':
				print "Listener %s is not running" % listener
				ep.write(listener + "\t : \t" + "STOPPED")
				ep.write('\n')
			else:
				print "Listener %s is running ...wweeeehhhhh!!!" % listener
				#ep.write(listener + "\t : \t" + "RUNNING")
				#ep.write('\n')
		ep.close()
		#send_email()
		
	except Exception, e:
		print "Some kind of error occurred!!"
		raise e
else:
	MSGLISTFILE=DROPZONE_ROOT + sys.argv[0] + "/" + sys.argv[0] + "_msglisteners.txt"
	if not os.path.exists((DROPZONE_ROOT+sys.argv[0])):
		MSGLISTFILE=DROPZONE_ROOT + sys.argv[0][:-1] + "/" + sys.argv[0] + "_msglisteners.txt"

	create_list_of_msglisteners(sys.argv[0],sys.argv[1])
	try:
		LISTENER_ERR_FILE=DROPZONE_ROOT + sys.argv[0] + "/" + sys.argv[0] + "_error_listeners.txt"
		if not os.path.exists((DROPZONE_ROOT+sys.argv[0])):
			LISTENER_ERR_FILE=DROPZONE_ROOT + sys.argv[0][:-1] + "/" + sys.argv[0] + "_error_listeners.txt"

		ep=open(LISTENER_ERR_FILE,"a+")
		print "Waiting.........."
		f=open(MSGLISTFILE)
		count=1
		for msgport in f.readlines():
			listener=msgport.split('=')[1].split(',')[0]
			print "Message Listener: ",listener
			status=AdminControl.getAttribute(msgport.strip(),'started')
			
			if status == 'false':
				print "Listener %s is not running" % listener
				ep.write(listener + "\t : \t" + "STOPPED")
				ep.write('\n')
			else:
				print "Listener %s is running ...wweeeehhhhh!!!" % listener
				#ep.write(listener + "\t : \t" + "RUNNING")
				#ep.write('\n')
		ep.close()
		#send_email()
	except Exception, e:
		print "Weird errors...."
		raise e
