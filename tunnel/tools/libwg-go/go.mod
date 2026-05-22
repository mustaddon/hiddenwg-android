module golang.zx2c4.com/wireguard/android

go 1.23.1

replace golang.zx2c4.com/wireguard => ../wireguard-go

require (
	golang.org/x/sys v0.33.0
	golang.zx2c4.com/wireguard v1.0.0
)

require (
	golang.org/x/crypto v0.38.0 // indirect
	golang.org/x/net v0.40.0 // indirect
	golang.zx2c4.com/wintun v0.0.0-20230126152724-0fa3db229ce2 // indirect
)
