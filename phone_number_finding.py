import phonenumbers
from phonenumbers import timezone
from phonenumbers import geocoder
from phonenumbers import carrier

# Getting user input
phone_number = input("Enter the phone number with country code: ")

# Parsing user input to phone number
p_n = phonenumbers.parse(phone_number)

# printing the timezone
t_z = timezone.time_zones_for_number(p_n)
print("Timezone is ",str(t_z))

# printing the location
location = geocoder.description_for_number(p_n,'en')
print("Location is ",str(location))

# printing the service provider
s_p = carrier.name_for_number(p_n,'en')
print("Service Provider is ",str(s_p))