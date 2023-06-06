def first_method(plan,first_arg):

    plan.print("Received this argument: {}".format(first_arg))

    return "response from the first method which received this argument: {}".format(first_arg)


def second_method(plan,first_arg, second_arg):

    plan.print("First argument received: {}".format(first_arg))

    plan.print("Second argument received: {}".format(second_arg))

    return "response from the second method which received these arguments: {}, {}".format(first_arg, second_arg)
    