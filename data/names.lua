local _M = {};

_M.MOD_PREFIX = 'flashcards-'

_M.flashcard = {}
_M.flashcard.ITEM = _M.MOD_PREFIX .. 'flashcard'
_M.flashcard.RECIPE = _M.flashcard.ITEM

_M.writer = {}
_M.writer.WRITE_RECIPE = _M.MOD_PREFIX .. 'write-recipe'
_M.writer.BUILDING = _M.MOD_PREFIX .. 'writer'
_M.writer.ITEM = _M.writer.BUILDING
_M.writer.RECIPE = _M.writer.ITEM
_M.writer.RECIPE_CATEGORY = _M.MOD_PREFIX .. 'write-recipe-category'
_M.writer.SIGNAL_RECEIVER = _M.MOD_PREFIX .. 'writer-signal-receiver'
_M.writer.READY_ANIMATION = _M.MOD_PREFIX .. 'writer-ready-animation'

_M.reader = {}
_M.reader.CONTAINER = _M.MOD_PREFIX .. 'reader'
_M.reader.ITEM = _M.reader.CONTAINER
_M.reader.RECIPE = _M.reader.CONTAINER
_M.reader.SIGNAL_SENDER = _M.MOD_PREFIX .. 'reader-signal-sender'

return _M;
