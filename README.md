## Cleaner mod for Minetest

---
### Description:

A [Minetest][] mod that can be used to remove/replace unknown entities, nodes, & items. Originally forked from [PilzAdam's ***clean*** mod][f.pilzadam].

---
### Licensing:

[MIT](LICENSE.txt)

---
### Requirements:

- Minetest 0.4.16 or newer
- Depends: none

---
### Usage:

There are three files in the world path that can be edited: `clean_entities.json`, `clean_nodes.json`, & `clean_items.json`. If they do not already exist with the server is started they will be created automatically.

They are formatted as follows:
```json
{
	"remove":
	[
		"creatures:ghost",
		"creatures:chicken",
		"creatures:sheep",
		"creatures:skeleton",
		"creatures:zombie",
		"creatures:oerkki",
		"creatures:shark",
	],
	"replace":
	{
		"biofuel:biofuel":"default:leaves",
		"helicopter:heli":"default:copper_lump",
		"spawneggs:ghost":"alternode:key",
		"spawneggs:oerkki":"default:mese_crystal",
		"unifieddyes:airbrush":"default:coal_lump",
	},
}
```

`remove` key works for nodes & entities. `replace` key works for nodes & items. Their functions are self-explanatory.

---
### Links:

- [![ContentDB](https://content.minetest.net/packages/AntumDeluge/cleaner/shields/title/)][ContentDB]
- [Forum](https://forum.minetest.net/viewtopic.php?t=18381)
- [Git repo](https://github.com/AntumMT/mod-cleaner)
- [Changelog](changelog.txt)
- [TODO](TODO.txt)


[Minetest]: http://www.minetest.net/
[f.pilzadam]: https://forum.minetest.net/viewtopic.php?t=2777
[ContentDB]: https://content.minetest.net/packages/AntumDeluge/cleaner/
