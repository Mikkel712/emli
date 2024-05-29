

myls() {
    mosquitto_sub -d -h localhost -u my_user -P my_password -t my_user/count
}


myls
