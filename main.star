IMAGE_ARG_KEY = "image"
IMAGE_DEFAULT = "quay.io/keycloak/keycloak:21.1.1"
SERVICE_NAME_ARG_KEY = "name"
SERVICE_NAME_DEFAULT = "keycloak-server"
REALM_NAME_ARG_KEY = "realm"
REALM_NAME_DEFAULT = "myrealm"
REALM_USER_ARG_KEY = "realm-user"
REALM_USER_DEFAULT = "myuser"
REALM_PASSWORD_ARG_KEY = "realm-password"
REALM_PASSWORD_DEFAULT = "RealmPassword321"
REALM_FIRST_NAME_ARG_KEY = "realm-user-first-name"
REALM_FIRST_NAME_DEFAULT = "Dave"
REALM_LAST_NAME_ARG_KEY = "realm-user-last-name"
REALM_LAST_NAME_DEFAULT = "Grohl"
CLIENT_ID_ARG_KEY = "client-id"
CLIENT_ID_DEFAULT = "myclient"

USER = "admin"
PASSWORD = "admin"
PORT_NAME = "http-admin"
PRIVATE_PORT_NUMBER = 8080
PUBLIC_PORT_NUMBER = 4770
APPLICATION_PROTOCOL = "http"

CMD = ["start-dev"]

KEYCLOAK_BIN_DIRPATH = "/opt/keycloak/bin/"
KEYCLOAK_CLI_NAME = "kcadm.sh"
KEYCLOAK_CLI_FILEPATH = KEYCLOAK_BIN_DIRPATH + KEYCLOAK_CLI_NAME
KEYCLOAK_APP_URL_WITH_PARAMS = "https://www.keycloak.org/app/#url=http://localhost:{}&realm={}&client={}"
KEYCLOAK_ADMIN_PANEL_URL = "http://localhost:{}"
KEYCLOAK_HTTP_ROOT_PATH = "/"

REALM_MASTER = "master"


def run(plan, args):
    image = args.get(IMAGE_ARG_KEY, IMAGE_DEFAULT)
    service_name = args.get(SERVICE_NAME_ARG_KEY, SERVICE_NAME_DEFAULT)
    realm_name = args.get(REALM_NAME_ARG_KEY, REALM_NAME_DEFAULT)
    realm_user = args.get(REALM_USER_ARG_KEY, REALM_USER_DEFAULT)
    realm_password = args.get(REALM_PASSWORD_ARG_KEY, REALM_PASSWORD_DEFAULT)
    realm_first_name = args.get(REALM_FIRST_NAME_ARG_KEY, REALM_FIRST_NAME_DEFAULT)
    realm_last_name = args.get(REALM_LAST_NAME_ARG_KEY, REALM_LAST_NAME_DEFAULT)
    client_id = args.get(CLIENT_ID_ARG_KEY, CLIENT_ID_DEFAULT)

    ports_config = {
        PORT_NAME: PortSpec(
            number = PRIVATE_PORT_NUMBER,
            application_protocol = APPLICATION_PROTOCOL,
            wait = "4m",
        )
    }

    public_ports_config = {
        PORT_NAME: PortSpec(
            number = PUBLIC_PORT_NUMBER,
            application_protocol = APPLICATION_PROTOCOL,
            wait = None,
        )
    }

    env_vars_config = {
        "KEYCLOAK_ADMIN": USER,
        "KEYCLOAK_ADMIN_PASSWORD": PASSWORD,
    }

    plan.print("Starting " + service_name + "...")

    keycloak_rc = ReadyCondition(
        recipe = GetHttpRequestRecipe(
            port_id = PORT_NAME,
            endpoint = KEYCLOAK_HTTP_ROOT_PATH
        ),
        field = "code",
        assertion= "==",
        target_value= 200
    )

    keycloak_service = plan.add_service(
        name = service_name,
        config = ServiceConfig(
            image = image,
            ports = ports_config,
            public_ports = public_ports_config,
            env_vars = env_vars_config,
            cmd = CMD,
            ready_conditions = keycloak_rc
        )
    )

    plan.print("Service " + service_name + " started")

    # STEP: Log in to the Admin Console
    config_credentials_cmd = getConfigCredentialsCmdForUserInRealm(USER, PASSWORD, REALM_MASTER)
        
    executeCmd(plan, service_name, config_credentials_cmd)

    # STEP: Create a realm
    plan.print("Creating a new realm with name '" + realm_name + "'...")

    create_realm_cmd = [
        KEYCLOAK_CLI_FILEPATH,
        "create",
        "realms",
        "-s",
        "realm="+realm_name,
        "-s",
        "enabled=true"
    ]
    
    executeCmd(plan, service_name, create_realm_cmd)

    plan.print("Realm '" + realm_name + "' created")

    # STEP: Create a user
    plan.print("Creating a new user '" + realm_user + "' in realm'" + realm_name + "'...")

    create_realm_user_cmd = [
        KEYCLOAK_CLI_FILEPATH,
        "create",
        "users",
        "-r",
        realm_name,
        "-s",
        "username="+realm_user,
        "-s",
        "firstName="+realm_first_name,
        "-s",
        "lastName="+realm_last_name,
        "-s",
        "enabled=true"
    ]
    
    executeCmd(plan, service_name, create_realm_user_cmd)

    set_realm_password_cmd = [
        KEYCLOAK_CLI_FILEPATH,
        "set-password",
        "-r",
        realm_name,
        "--username",
        realm_user,
        "--new-password",
        realm_password
    ]
    
    executeCmd(plan, service_name, set_realm_password_cmd)

    # STEP: Log in to the Account Console
    config_credentials_cmd = getConfigCredentialsCmdForUserInRealm(realm_user, realm_password, realm_name)
        
    executeCmd(plan, service_name, config_credentials_cmd)

    plan.print("New user '" + realm_user + "' successfully created in realm '" + realm_name + "'")

    # STEP: Secure the first application
    
    # First we have to login as the admin again
    config_credentials_cmd = getConfigCredentialsCmdForUserInRealm(USER, PASSWORD, REALM_MASTER)
        
    executeCmd(plan, service_name, config_credentials_cmd)

    # Then we create the application/client
    plan.print("Creating new client '" + client_id + "' in realm '" + realm_name + "'...")

    create_client_cmd = [
        KEYCLOAK_CLI_FILEPATH,
        "create",
        "clients",
         "-r",
        realm_name,
        "-s",
        "clientId="+client_id,
        "-s",
        'redirectUris=["https://www.keycloak.org/app/*"]', #TODO add argument and constants
        "-s",
        'webOrigins=["https://www.keycloak.org"]', #TODO add argument and constants
        "-s",
        "directAccessGrantsEnabled=true",
        "-s",
        "publicClient=true",
        "-s",
        "enabled=true",
    ]

    executeCmd(plan, service_name, create_client_cmd)

    plan.print("New client '" + client_id + "' successfully created in realm'" + realm_name + "'")

    public_port_number_str = "%d" % (PUBLIC_PORT_NUMBER) 

    application_URL = KEYCLOAK_APP_URL_WITH_PARAMS.format(public_port_number_str, realm_name, client_id)
    admin_panel_URL = KEYCLOAK_ADMIN_PANEL_URL.format(public_port_number_str)

    msg = "Now you can use the realm's user credentials [ " + realm_user + " | " + realm_password + " ] "
    msg += "to login into the application already set through this URL: " + application_URL + " "
    msg += "You can also use the admin credentials [ " + USER + " | " + PASSWORD + " ] to login into the admin panel throught this URL: " + admin_panel_URL

    return msg

def executeCmd(plan, service_name, cmd):
    exec_recipe = ExecRecipe(
        command = cmd,
    )

    result = plan.exec(
        service_name = service_name,
        recipe = exec_recipe,
    )

    return result

def getConfigCredentialsCmdForUserInRealm(user, password, realm):
    port_number_str = "%d" % (PRIVATE_PORT_NUMBER) 

    config_credentials_cmd = [
        KEYCLOAK_CLI_FILEPATH,
        "config",
        "credentials",
        "--server",
        "http://localhost:"+port_number_str,
        "--realm",
        realm,
        "--user",
        user,
        "--password",
        password
    ]

    return config_credentials_cmd
    