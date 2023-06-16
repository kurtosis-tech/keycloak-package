SERVICE_NAME_ARG_KEY = "name"
SERVICE_NAME_DEFAULT = "my-service-name"

CONTRACT_NAME_ARG_KEY = "contract"
CONTRACT_NAME_DEFAULT = "my-contract"

def run():

    return "Executed the run method without any argument"

def first_method():

    return "response from the first method"

def second_method(plan, first_arg):

    plan.print("Received this argument: {}".format(first_arg))

    return "response from the second method which received this argument: {}".format(first_arg)

def theird_method(plan, first_arg, second_arg):

    plan.print("First argument received: {}".format(first_arg))

    plan.print("Second argument received: {}".format(second_arg))

    return "response from the theird method which received these arguments: {}, {}".format(first_arg, second_arg)

def fourth_method(plan, first_arg, second_arg, args):

    plan.print("First argument received: {}".format(first_arg))

    plan.print("Second argument received: {}".format(second_arg))

    service_name = args.get(SERVICE_NAME_ARG_KEY, SERVICE_NAME_DEFAULT)

    contract_name = args.get(CONTRACT_NAME_ARG_KEY, CONTRACT_NAME_DEFAULT)

    plan.print("Received service name: {} and contract name: {}".format(service_name, contract_name))

    return "response from the fourth method which received these arguments: {}, {}, {}".format(first_arg, second_arg, args)

def last_method(first_arg, second_arg):

    return "response from the last method which received these arguments: {}, {}".format(first_arg, second_arg)
