IMAGE_ARG_KEY = "image"
IMAGE_DEFAULT = "quay.io/keycloak/keycloak:21.1.1"
SERVICE_NAME_ARG_KEY = "name"
SERVICE_NAME_DEFAULT = "keycloak-server"
USER_ARG_KEY = "user"
USER_DEFAULT = "admin"
PASSWORD_ARG_KEY = "password"
PASSWORD_DEFAULT = "admin"

PORT_NAME = "http-admin"
PORT_NUMBER = 8080
APPLICATION_PROTOCOL = "http"

CMD = ["start-dev"]

def run(plan, args):
    image = args.get(IMAGE_ARG_KEY, IMAGE_DEFAULT)
    service_name = args.get(SERVICE_NAME_ARG_KEY, SERVICE_NAME_DEFAULT)
    user = args.get(USER_ARG_KEY, USER_DEFAULT)
    password = args.get(PASSWORD_ARG_KEY, PASSWORD_DEFAULT)
   
    ports_config = {
        PORT_NAME: PortSpec(
            number = PORT_NUMBER,
            application_protocol = APPLICATION_PROTOCOL,
            wait = "4m",
        )
    }

    env_vars_config = {
        "KEYCLOAK_ADMIN": user,
        "KEYCLOAK_ADMIN_PASSWORD": password,
    }

    plan.print("Starting " + service_name + "...")

    plan.add_service(
        name = service_name,
        config = ServiceConfig(
            image = image,
            ports = ports_config,
            env_vars = env_vars_config,
            cmd = CMD,
        )
    )

    plan.print("Service " + service_name + " started")
