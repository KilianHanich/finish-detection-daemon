#!/usr/bin/python3
# SPDX-License-Identifier: EUPL-1.2
# SPDX-FileCopyrightText: 2023 Kilian Hanich <khanich.opensource@gmx.de>

import sys
import pyinotify
import os
import subprocess as sp
import signal

DIRECTORY="/wd"
print(sys.argv)
customers = set(sys.argv[1:])

class EventHandler(pyinotify.ProcessEvent):
	def __init__(self):
		pyinotify.ProcessEvent.__init__(self)
	def process_IN_CREATE(self, event):
		print("new file:", event.pathname, flush=True)
		try:
			customer = '.'.join(os.path.basename(event.pathname).split('.')[:-1])
			customers.remove(customer)
			print("customer", customer, "finished", flush=True)
			os.remove(event.pathname)
		except:
			pass
		if len(customers) == 0:
			print("finished")
			sys.exit(0)

signal.signal(signal.SIGTERM, lambda _,__: sys.exit(1))
wm = pyinotify.WatchManager()
notifier = pyinotify.Notifier(wm, EventHandler())
watch_descriptors = wm.add_watch(DIRECTORY, pyinotify.IN_CREATE)
notifier.loop()
