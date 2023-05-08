Keycloak Package
============
This is a [Kurtosis package][kurtosis-packages] for starting a Keycloak server with a preconfigured application. This package simplifies and automates the step described in [Keycloak getting started with the Docker version doc][keycloak-docker]

Run this package
----------------
If you have [Kurtosis installed][install-kurtosis], run:

```bash
kurtosis run github.com/kurtosis-tech/keycloak-package
```

When tha package finishes initializing you will see a message like this (in green color)

```bash
"Now you can use the realm's user credentials [ myuser | RealmPassword321 ] to login into the application already set through this URL: https://www.keycloak.org/app/#url=http://localhost:4770&realm=myrealm&client=myclient You can also use the admin credentials [ admin | admin ] to login into the admin panel throught this URL: http://localhost:4770"
```

You can click on the first link for opening the Keycloak application example, and then, you can login using the credentials printed in the message in order to see how this application is integraded witht he Keycloak server that you already started with this package.


If you don't have Kurtosis installed, [click here to run this package on the Kurtosis playground](https://gitpod.io/#KURTOSIS_PACKAGE_LOCATOR=https%3A%2F%2Fgithub.com%2Fkurtosis-tech%2Fkeycloak-package).

To blow away the created [enclave][enclaves-reference], run `kurtosis clean -a`.


#### Configuration

<details>
    <summary>Click to see configuration</summary>

You can configure this package using the following JSON structure (though note that `//` lines aren't valid JSON, so you must remove them!). The default value each parameter will take if omitted is shown here:

```javascript
{
    // The Docker image that will be run
    "image": "quay.io/keycloak/keycloak:21.1.1",

    // The name given to the service that gets added
    "name": "keycloak-server",

    // The name of the realm that will be created
    "realm": "myrealm",

    // The name of the realm's user that will be created
    "realm-user": "myuser",

    // The password given to the created realm's user
    "realm-password": "RealmPassword321",

    // The first name given to the created realm's user
    "realm-user-first-name": "RealmUserFirstName",

    // The last name given to the created realm's user
    "realm-user-last-name": "RealmUserLastName",

    // The client id used for configuring the application
    "client-id": "myclient",
}
```

For example:

```bash
kurtosis run github.com/kurtosis-tech/postgres-package '{"realm": "myrealm",  "realm-user": "myuser", "realm-password": "RealmPassword321"}'
```

</details>

How this package can growth?
----------------------------
1. Ingrate this package with [Postgres package][postgres-package] using [composability][composability-in-docs]
1. Include a configure an SSL certificate
1. Define your own app and connec it easily with Keycloak server


Develop on this package
-----------------------
1. [Install Kurtosis][install-kurtosis]
1. Clone this repo
1. For your dev loop, run `kurtosis clean -a && kurtosis run .` inside the repo directory


<!-------------------------------- LINKS ------------------------------->
[kurtosis-packages]: https://docs.kurtosis.com/concepts-reference/packages
[install-kurtosis]: https://docs.kurtosis.com/install
[enclaves-reference]: https://docs.kurtosis.com/concepts-reference/enclaves
[keycloak-docker]: https://www.keycloak.org/getting-started/getting-started-docker
[postgres-package]: https://github.com/kurtosis-tech/postgres-package
[composability-in-docs]: https://docs.kurtosis.com/explanations/reusable-environment-definitions#what-does-a-reusable-solution-look-like 
