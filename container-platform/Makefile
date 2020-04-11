
create: c_paas c_api_gateway c_functions c_apps

delete: d_apps d_functions d_api_gateway d_paas

################################################################################
c_paas:
	make create --directory ../hephy-setup

c_api_gateway:
	make create --directory ../kong-ingress-on-kubernetes

c_functions:
	make create --directory ../figuring-out-kubeless
	make deploy --directory ../figuring-out-kubeless

c_apps:
	make create --directory ../hephy-setup

################################################################################
d_paas:
	-make delete --directory ../hephy-setup

d_api_gateway:
	-make delete --directory ../kong-ingress-on-kubernetes

d_functions:
	-make undeploy --directory ../figuring-out-kubeless
	-make delete --directory ../figuring-out-kubeless

d_apps:
	-make delete --directory ../hephy-setup
