from pysnmp.hlapi import SnmpEngine, CommunityData, UdpTransportTarget, ContextData, ObjectType, ObjectIdentity, nextCmd

ip = '192.168.1.10'
community = 'public'

oid_ifDescr = '1.3.6.1.2.1.2.2.1.2'
oid_ifOperStatus = '1.3.6.1.2.1.2.2.1.8'

# ดึงชื่อพอร์ต
ports = [str(varBind[1]) for errorIndication, errorStatus, errorIndex, varBinds in nextCmd(
    SnmpEngine(),
    CommunityData(community),
    UdpTransportTarget((ip, 161)),
    ContextData(),
    ObjectType(ObjectIdentity(oid_ifDescr)),
    lexicographicMode=False
) for varBind in varBinds]

# ดึงสถานะพอร์ต
statuses = [int(varBind[1]) for errorIndication, errorStatus, errorIndex, varBinds in nextCmd(
    SnmpEngine(),
    CommunityData(community),
    UdpTransportTarget((ip, 161)),
    ContextData(),
    ObjectType(ObjectIdentity(oid_ifOperStatus)),
    lexicographicMode=False
) for varBind in varBinds]

for port, status in zip(ports, statuses):
    state = "UP" if status == 1 else "DOWN"
    print(f"{port} : {state}")
