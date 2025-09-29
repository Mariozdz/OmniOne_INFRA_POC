from diagrams import Cluster, Diagram, Edge
from diagrams.azure.security import KeyVaults
from diagrams.custom import Custom
from diagrams.azure.network import PrivateEndpoint, FrontDoors, LoadBalancers, ApplicationGateway, LocalNetworkGateways
from diagrams.azure.compute import CloudsimpleVirtualMachines
from diagrams.azure.database import DatabaseForPostgresqlServers
from diagrams.azure.identity import ADB2C, Users


with Diagram("OmniOneDID", show=False):

    user = Users("User")
    admin_user = Users("Admin User")

    with Cluster("VPC"):
        vault = KeyVaults("Key Vault Certificate")
        front_door = FrontDoors("FrontDoor")
        front_door >> Edge(color="lightgreen") >> vault

        with Cluster("App Gateway Subnet"):
            app_gateway = ApplicationGateway("Application Gateway")
            front_door >> Edge(color="lightgreen") >> app_gateway
        
        with Cluster("Public Subnet"):
            web_vm = Custom("Web VM", "./icons/az_vm.png")
            web_gateway = LocalNetworkGateways("Web Gateway")
            app_gateway  >> Edge(color="lightgreen") >>  web_vm
        
        with Cluster("Azubre Bastion Subnet"):
            bastion = Custom("Cert manager", "./icons/bastion-icon.png")
            bastion >> Edge(color="red") >> web_vm

        with Cluster("Private WAS Subnet"):
            was_vm_1 = Custom("Was VM 1", "./icons/az_vm.png")
            was_vm_2 = Custom("Was VM 2", "./icons/az_vm.png")
            was_vm_3 = Custom("Was VM 3", "./icons/az_vm.png")
            was_balancer = LoadBalancers("Was Balancer")
            was_gateway = LocalNetworkGateways("WAS Gateway")
            web_vm >> Edge(color="orange") >> was_balancer
            was_balancer >> Edge(color="orange") >> was_vm_1
            was_balancer >> Edge(color="orange") >> was_vm_2
            was_balancer >> Edge(color="orange") >> was_vm_3
        
        with Cluster("Communication Subnet"):
            private_comm_endpoint = PrivateEndpoint("Communication Private Endpoint")
            communication_gateway = LocalNetworkGateways("Communication Gateway")
            communication_service = Custom("Communication Service", "./icons/communication-icon.png")
            was_vm_1 >> Edge() >> private_comm_endpoint
            private_comm_endpoint >> Edge() >> communication_service
        
        with Cluster("DB Subnet"):
            db_postgress = DatabaseForPostgresqlServers("Postgress DB")
            private_db_endpoint = PrivateEndpoint("DB Private Endpoint")
            was_vm_1 >> Edge(color="purple") >> private_db_endpoint
            private_db_endpoint >> Edge(color="purple") >> db_postgress

        with Cluster("Entra - B2C subnet"):
            add_b2c = ADB2C("ADD B2C")
            private_identity_endpoint = PrivateEndpoint("Identity Private Endpoint")
    
    user >> Edge(color="lightgreen") >> front_door
    admin_user >> Edge(color="red") >> bastion
    bastion >> Edge(color="red") >> was_vm_1
    bastion >> Edge(color="red") >> was_vm_2
    bastion >> Edge(color="red") >> was_vm_3

    was_vm_2 >> Edge(color="purple") >> private_db_endpoint
    was_vm_3 >> Edge(color="purple") >> private_db_endpoint

        

        