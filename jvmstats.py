import os, sys
import time

processname=sys.argv[0]
(year,mon,day)=time.localtime(time.time())[0:3]
if mon <= 9: mon="0"+str(mon)
if day <= 9: day="0"+str(day)
FILENAME="/proj/cdb/was/logs/" + str(processname) + "_jvmstats.log." + str(year) + "-" + str(mon) + "-" + str(day)
perfstr=AdminControl.queryNames("type=Perf,process=%s,*" % (processname))
perfobj=AdminControl.makeObjectName(perfstr)

jvmstr=AdminControl.queryNames("type=JVM,process=%s,*" % (processname))
jvmobj=AdminControl.makeObjectName(jvmstr)

jvmstats=AdminControl.invoke_jmx(perfobj,"getStatsObject", [jvmobj, java.lang.Boolean('true')], ['javax.management.ObjectName','java.lang.Boolean'])

HeapSize=jvmstats.getStatistic("HeapSize").getCurrent()
Allocated_HeapSize=HeapSize/1024
UsedHeapSize=jvmstats.getStatistic("UsedMemory").getCount()
UsedHeapSize=UsedHeapSize/1024

processCpuUsage=jvmstats.getStatistic("ProcessCpuUsage").getCount()

hour=time.localtime(time.time())[3]
minutes=time.localtime(time.time())[4]
if minutes <= 9:
        strmin="0"+str(minutes)
else:
        strmin=str(minutes)

if hour <= 9:
        strhour="0"+str(hour)
else:
        strhour=str(hour)
chtime=strhour+":"+strmin
data=chtime + "," + str(Allocated_HeapSize) + "," + str(UsedHeapSize) + "\n"

if os.path.exists(FILENAME):
        fh=open(FILENAME, "a+")
        fh.write(data)
else:
        fh=open(FILENAME, "w+")
        fh.write("TIME,ALLOCATED HEAPSIZE,USED HEAP SIZE\n")
        fh.write(data)

fh.close()
