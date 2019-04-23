oc project app-storage
oc get pod
oc describe po <heketi_pod>
oc describe po heketi-storage-1-qx925

oc rsh <heketi_pod> heketi-cli -s http://localhost:8080 --user admin --secret <admin_key> topology info
oc rsh heketi-storage-1-qx925  heketi-cli -s http://localhost:8080 --user admin --secret b4Tbnht6EfxjNQ7TpHcC4fIkftaga8Wt4f4ce3cMbuY= topology info
oc rsh heketi-storage-1-qx925  heketi-cli -s http://localhost:8080 --user admin --secret b4Tbnht6EfxjNQ7TpHcC4fIkftaga8Wt4f4ce3cMbuY= device add --help

oc rsh heketi-storage-1-ff995  heketi-cli -s http://localhost:8080 --user admin --secret b4Tbnht6EfxjNQ7TpHcC4fIkftaga8Wt4f4ce3cMbuY= topology info | grep 'Node Id'
	Node Id: 62677c42440b4c1435b49ffc07b58ad1
	Node Id: 7afa8bbe1539575c3695f63b8f6c3918
	Node Id: 8646350701222331fad017fecbc89345

oc rsh heketi-storage-1-ff995  heketi-cli -s http://localhost:8080 --user admin --secret b4Tbnht6EfxjNQ7TpHcC4fIkftaga8Wt4f4ce3cMbuY= device add --name=/dev/sdb1 --node=62677c42440b4c1435b49ffc07b58ad1
