kall() {
  kubectl get $1 --all-namespaces
}

find_po() {
  k get po | grep $1 | awk '{ print $1 }'
}
