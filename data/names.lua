local names = {};
names.MOD_PREFIX = 'flashcards-'

names.flashcard = {}
names.flashcard.ITEM = names.MOD_PREFIX .. 'flashcard'
names.flashcard.RECIPE = names.flashcard.ITEM

names.writer = {}
names.writer.WRITE_RECIPE = names.MOD_PREFIX .. 'write-recipe'
names.writer.BUILDING = names.MOD_PREFIX .. 'writer'
names.writer.ITEM = names.writer.BUILDING
names.writer.RECIPE = names.writer.ITEM
names.writer.SIGNAL_RECEIVER = names.MOD_PREFIX .. 'writer-signal-receiver'

names.reader = {}
names.reader.BUILDING = names.MOD_PREFIX .. 'reader'
names.reader.ITEM = names.reader.BUILDING
names.reader.RECIPE = names.reader.BUILDING

return names;
