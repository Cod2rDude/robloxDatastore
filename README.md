## Datastore

It's a datastore module for roblox that uses tables to save content and has backup datastores.

### How it works

  1. File System
     PLAYER
		  |
		  |--> datas
				|
				|--> customDatas
				|			|
				|			|--> GDS0
				|			|		|
				|			|		|-> Values
				|			|
				|			|--> GDS1
				|					|
				|					|-> Values
				|
				|--> metaData
							|
							|--> playTime => int
							|
							|--> lastLogin => int - unixEpoch
							|
							|--> firstTimePlay => bool

     (PS: I forgor to add metada)

