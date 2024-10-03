echo -e "Enter the neuvector version you want to install : "
read version

RED='\033[0;31m'
RESET="\e[0m"
UL='\033[4m'
GREEN='\033[0;37m'
echo -e "----------------------------------------------------------------------------------------------------"
echo -e "${RED}Creating the NeuVector namespace and the required service accounts  ===> ${GREEN}"
echo -e "----------------------------------------------------------------------------------------------------"

kubectl create namespace neuvector
kubectl create sa controller -n neuvector
kubectl create sa enforcer -n neuvector
kubectl create sa basic -n neuvector
kubectl create sa updater -n neuvector
kubectl create sa scanner -n neuvector
kubectl create sa registry-adapter -n neuvector
kubectl create sa cert-upgrader -n neuvector
sleep 5
echo -e "----------------------------------------------------------------------------------------------------"
echo -e "${RED}Labeling the NeuVector namespace with privileged profile for deploying on a PSA enabled cluster===>${GREEN}"
echo -e "----------------------------------------------------------------------------------------------------"
kubectl label  namespace neuvector "pod-security.kubernetes.io/enforce=privileged"

echo -e "----------------------------------------------------------------------------------------------------"
echo -e "${RED}Applying CRD's: ===> ${GREEN} "
echo -e "----------------------------------------------------------------------------------------------------"

kubectl apply -f https://raw.githubusercontent.com/neuvector/manifests/main/kubernetes/5.4.0/crd-k8s-1.19.yaml
kubectl apply -f https://raw.githubusercontent.com/neuvector/manifests/main/kubernetes/5.4.0/waf-crd-k8s-1.19.yaml
kubectl apply -f https://raw.githubusercontent.com/neuvector/manifests/main/kubernetes/5.4.0/dlp-crd-k8s-1.19.yaml
kubectl apply -f https://raw.githubusercontent.com/neuvector/manifests/main/kubernetes/5.4.0/com-crd-k8s-1.19.yaml
kubectl apply -f https://raw.githubusercontent.com/neuvector/manifests/main/kubernetes/5.4.0/vul-crd-k8s-1.19.yaml
kubectl apply -f https://raw.githubusercontent.com/neuvector/manifests/main/kubernetes/5.4.0/admission-crd-k8s-1.19.yaml

echo -e "----------------------------------------------------------------------------------------------------"
echo -e "${RED}Creating clusterrole , role rolebinding and clusterrolebinding  ===>${GREEN}"
echo -e "----------------------------------------------------------------------------------------------------"

kubectl create clusterrole neuvector-binding-app --verb=get,list,watch,update --resource=nodes,pods,services,namespaces
kubectl create clusterrole neuvector-binding-rbac --verb=get,list,watch --resource=rolebindings.rbac.authorization.k8s.io,roles.rbac.authorization.k8s.io,clusterrolebindings.rbac.authorization.k8s.io,clusterroles.rbac.authorization.k8s.io
kubectl create clusterrolebinding neuvector-binding-app --clusterrole=neuvector-binding-app --serviceaccount=neuvector:controller
kubectl create clusterrolebinding neuvector-binding-rbac --clusterrole=neuvector-binding-rbac --serviceaccount=neuvector:controller
kubectl create clusterrole neuvector-binding-admission --verb=get,list,watch,create,update,delete --resource=validatingwebhookconfigurations,mutatingwebhookconfigurations
kubectl create clusterrolebinding neuvector-binding-admission --clusterrole=neuvector-binding-admission --serviceaccount=neuvector:controller
kubectl create clusterrole neuvector-binding-customresourcedefinition --verb=watch,create,get,update --resource=customresourcedefinitions
kubectl create clusterrolebinding neuvector-binding-customresourcedefinition --clusterrole=neuvector-binding-customresourcedefinition --serviceaccount=neuvector:controller
kubectl create clusterrole neuvector-binding-nvsecurityrules --verb=get,list,delete --resource=nvsecurityrules,nvclustersecurityrules
kubectl create clusterrole neuvector-binding-nvadmissioncontrolsecurityrules --verb=get,list,delete --resource=nvadmissioncontrolsecurityrules
kubectl create clusterrole neuvector-binding-nvdlpsecurityrules --verb=get,list,delete --resource=nvdlpsecurityrules
kubectl create clusterrole neuvector-binding-nvwafsecurityrules --verb=get,list,delete --resource=nvwafsecurityrules
kubectl create clusterrolebinding neuvector-binding-nvsecurityrules --clusterrole=neuvector-binding-nvsecurityrules --serviceaccount=neuvector:controller
kubectl create clusterrolebinding neuvector-binding-view --clusterrole=view --serviceaccount=neuvector:controller
kubectl create clusterrolebinding neuvector-binding-nvwafsecurityrules --clusterrole=neuvector-binding-nvwafsecurityrules --serviceaccount=neuvector:controller
kubectl create clusterrolebinding neuvector-binding-nvadmissioncontrolsecurityrules --clusterrole=neuvector-binding-nvadmissioncontrolsecurityrules --serviceaccount=neuvector:controller
kubectl create clusterrolebinding neuvector-binding-nvdlpsecurityrules --clusterrole=neuvector-binding-nvdlpsecurityrules --serviceaccount=neuvector:controller
kubectl create role neuvector-binding-scanner --verb=get,patch,update,watch --resource=deployments -n neuvector
kubectl create rolebinding neuvector-binding-scanner --role=neuvector-binding-scanner --serviceaccount=neuvector:updater --serviceaccount=neuvector:controller -n neuvector
kubectl create role neuvector-binding-secret --verb=get,list,watch --resource=secrets -n neuvector
kubectl create rolebinding neuvector-binding-secret --role=neuvector-binding-secret --serviceaccount=neuvector:controller --serviceaccount=neuvector:enforcer --serviceaccount=neuvector:scanner --serviceaccount=neuvector:registry-adapter -n neuvector
kubectl create clusterrole neuvector-binding-nvcomplianceprofiles --verb=get,list,delete --resource=nvcomplianceprofiles
kubectl create clusterrolebinding neuvector-binding-nvcomplianceprofiles --clusterrole=neuvector-binding-nvcomplianceprofiles --serviceaccount=neuvector:controller
kubectl create clusterrole neuvector-binding-nvvulnerabilityprofiles --verb=get,list,delete --resource=nvvulnerabilityprofiles
kubectl create clusterrolebinding neuvector-binding-nvvulnerabilityprofiles --clusterrole=neuvector-binding-nvvulnerabilityprofiles --serviceaccount=neuvector:controller
kubectl apply -f https://raw.githubusercontent.com/neuvector/manifests/main/kubernetes/5.4.0/neuvector-roles-k8s.yaml
kubectl create role neuvector-binding-lease --verb=create,get,update --resource=leases -n neuvector
kubectl create rolebinding neuvector-binding-cert-upgrader --role=neuvector-binding-cert-upgrader --serviceaccount=neuvector:cert-upgrader -n neuvector
kubectl create rolebinding neuvector-binding-job-creation --role=neuvector-binding-job-creation --serviceaccount=neuvector:controller -n neuvector
kubectl create rolebinding neuvector-binding-lease --role=neuvector-binding-lease --serviceaccount=neuvector:controller --serviceaccount=neuvector:cert-upgrader -n neuvector

echo -e "----------------------------------------------------------------------------------------------------"
echo -e "${RED}Checkingthe neuvector/controller and neuvector/updater service accounts  ===>${GREEN}"
echo -e "----------------------------------------------------------------------------------------------------"


kubectl get ClusterRoleBinding neuvector-binding-app neuvector-binding-rbac neuvector-binding-admission neuvector-binding-customresourcedefinition neuvector-binding-nvsecurityrules neuvector-binding-view neuvector-binding-nvwafsecurityrules neuvector-binding-nvadmissioncontrolsecurityrules neuvector-binding-nvdlpsecurityrules -o wide

echo -e "----------------------------------------------------------------------------------------------------"
echo -e "${RED}Creating the NeuVector services and pods  ===>${GREEN}"
echo -e "----------------------------------------------------------------------------------------------------"

kubectl apply -f https://raw.githubusercontent.com/amolvkharche/neuvector/main/v5.4.0/${version}.yaml

sleep 5

echo -e "----------------------------------------------------------------------------------------------------"
echo -e "${RED}Changing LoadBalancer type to NodePort service  ===>${GREEN}"
echo -e "----------------------------------------------------------------------------------------------------"
kubectl -n neuvector patch svc neuvector-service-webui -p '{"spec": {"ports": [],"type": "NodePort"}}'

node_ip=$(kubectl get node -o wide | awk '{print $7}' |grep -v EXTERNAL|head -1)
port=$(kubectl get svc -n neuvector| grep -i neuvector-service-webui| awk '{print $5}'|cut -c 6-10)
echo -e "----------------------------------------------------------------------------------------------------"
echo -e "${RED}You can access Neuvector GUI using  ===> ${RESET} ${UL} https:$node_ip":"$port ${RESET}"
echo -e "----------------------------------------------------------------------------------------------------"
