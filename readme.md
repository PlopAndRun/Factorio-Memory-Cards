# Factorio Memory Cards
This mod adds a new item that can store circuit network information. This opens a whole new ARRAY of possibilities, the SPACE is the limit! Store bulk data, create loops, send them in trains or in spaceships.

* Fully automatable reading and writing
* Enough space to store every signal in the network
* Works in space and spaceships in Space Exploration
* Compatible with Ultracube
* Blueprints are supported

## New Content
This mod adds a memory card item, a memory card writer machine and a memory card reader machine.

A memory card can store any amount of circuit network signals. 

To write signals on a card you need to insert it into a memory cards writer. When the write operation is finished all signals from both connected wires will get saved on the memory card. 

To read the stored signals you need to insert a card into a memory card reader. When a card is inserted, the reader will send a special signal plus the card's contents to the connected wires.

Inserters can insert and remove cards into writer and readers, and only one card can be inserted at any time.

You can view and edit any memory card with the helpful editor that can be accessed from shortcuts (near other tools like copy, pase and the blueprint creator). This editor shows you every signal that is written on the memory card and it allows you to edit these signals manually. The editor has an internal memory that can be used to transfer signals from one card to another.

## Known issues

* The memory card writer shows a "Disabled by script" message when it is working properly. This is an implementation detail and does not affect functionality.
* Currently, pasting in Blueprint Sandboxes is not supported, but blueprints made in blueprint sandboxes manually will work in the real world.