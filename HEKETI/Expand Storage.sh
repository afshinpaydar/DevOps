oc project app-storage
oc get pod
oc describe po <heketi_pod>
oc describe po heketi-storage-1-qx925

oc describe po heketi-storage-1-gsj9w |  grep HEKETI_ADMIN_KEY
      HEKETI_ADMIN_KEY:                0x6LamEHYAAgN62Ka3l3HTh6TwRLKCSYx0F/rv23yUU=

oc rsh <heketi_pod> heketi-cli -s http://localhost:8080 --user admin --secret <admin_key> topology info
oc rsh heketi-storage-1-qx925  heketi-cli -s http://localhost:8080 --user admin --secret b4Tbnht6EfxjNQ7TpHcC4fIkftaga8Wt4f4ce3cMbuY= topology info

oc rsh heketi-storage-1-qx925  heketi-cli -s http://localhost:8080 --user admin --secret b4Tbnht6EfxjNQ7TpHcC4fIkftaga8Wt4f4ce3cMbuY= device add --help

oc rsh heketi-storage-1-gsj9w  heketi-cli -s http://localhost:8080 --user admin --secret 0x6LamEHYAAgN62Ka3l3HTh6TwRLKCSYx0F/rv23yUU= topology info | grep 'Node Id'
	Node Id: 1d22a43008f3742d9a3b20edcbf23b50
	Node Id: 4c09f7bec67805198e06023827576782
	Node Id: 7ed4159c956989d7bbd15a2dd3ae6a53

oc rsh heketi-storage-1-gsj9w  heketi-cli -s http://localhost:8080 --user admin --secret 0x6LamEHYAAgN62Ka3l3HTh6TwRLKCSYx0F/rv23yUU= device add --name=/dev/sdd --node=1d22a43008f3742d9a3b20edcbf23b50
Device added successfully

oc rsh heketi-storage-1-gsj9w  heketi-cli -s http://localhost:8080 --user admin --secret 0x6LamEHYAAgN62Ka3l3HTh6TwRLKCSYx0F/rv23yUU= device add --name=/dev/sdd --node=4c09f7bec67805198e06023827576782
Device added successfully

oc rsh heketi-storage-1-gsj9w  heketi-cli -s http://localhost:8080 --user admin --secret 0x6LamEHYAAgN62Ka3l3HTh6TwRLKCSYx0F/rv23yUU= device add --name=/dev/sdd --node=7ed4159c956989d7bbd15a2dd3ae6a53
Device added successfully
