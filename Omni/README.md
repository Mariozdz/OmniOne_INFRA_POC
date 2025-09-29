## Propuesta de implementación de infraestructura OmniOne OpenDID

Propuesta original basada en AWS cloud provider: 

![Diagrama Basa en AWS](/Omni/resources/DiagramaAws.jpeg)

Debido a la previa implementación de ejercicios en Azure, se decide realizar la conversión de la propuesta de infraestructura basada en AWS a Azure. Esto también con el fin de tener una vista comparativa entre la infraestructura y servicios disponibles entre los distintos proveedores de la nube.

Entre los principales cambios que se proponen en relación a la seguridad, se encuentran:

- Implementación de Application Gateway. Este elemento provee gestión de tráfico web en capa 7 que incluye WAF, TLS además de balanceo de tráfico basado en URL por lo que no está asociado únicamente a un BackEnd y puede ser reutilizado. En la figura adjunta se muestra su implementación en una subnet propia la cual no necesita mayor configuración en relación a NSG, ya que normalmente este se ajusta directamente en el Application Gateway hacia N backends.

- Separación del bastión. El Bastion de Azure es definido en una propia subred (obligatorio a nivel de infraestructura en Azure) lo que permite que este administre distintos componentes a través de distintas sub redes sin exponer una sub red especifica a malas configuraciones o ataques de acceso como en el caso de la propuesta original, donde dicho bastión está en una subred compartida con el LoadBalancer y el servicio web.

- Implementación de un Internal Load Balancer en la subred WAS. Este componente está restringido a manejar tráfico únicamente dentro de las sub redes privadas, recibe y distribuye trafico http/https de una subred a otra y puede ser estrictamente restringido mediante la implementación de NSG.

- Implementación de Private Endpoint para conexión de servicios de Azure. Es básicamente un NIC privado que permite el tráfico interno de redes virtuales privadas a servicios externos que provee Azure sin necesidad de exponerse a conexión de internet, además de que permiten la configuración de reglas estrictas mediante NSG y firewall.

- Eliminación de FrontDoor (cloudform en AWS). Esto debido a que se espera que los usuarios sean a nivel regional especifico, además de que el Application Gateway es capaz de proveer la mayoría de las funcionalidades de frontdoor, incluyendo protección contra ataques comunes, balanceo de carga, enrutamiento, función como private endpoint, SSL/TLS entre otros.

![Diagrama](/Omni/resources/Diagrama.png)