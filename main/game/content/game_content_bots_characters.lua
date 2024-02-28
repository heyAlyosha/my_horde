-- Характеры
local M = {
	-- Любит капканы
	trap = {
		favorite_artifacts = {"trap", "catch"},
		counts_step = {
			trap = {1,2},
			catch = {0,1},
			speed_caret = {0,1},
			accuracy = {0,1},
			bank = {0,0},
			try = {0,0},
		},
		characteristics_step = {
			accuracy = 3,
			speed_caret = 3
		}
	},
	-- Любит захваты
	catch = {
		favorite_artifacts = {"catch", "trap"},
		counts_step = {
			trap = {0,1},
			catch = {1,3},
			speed_caret = {0,1},
			accuracy = {0,1},
			bank = {1,2},
			try = {0,0},
		},
		characteristics_step = {
			accuracy = 3,
			speed_caret = 3
		}
	},
	-- Любит банки
	bank = {
		favorite_artifacts = {"bank", "catch"},
		counts_step = {
			trap = {0,0},
			catch = {0,1},
			speed_caret = {0,0},
			accuracy = {0,0},
			bank = {3,6},
			try = {1,2},
		},
		characteristics_step = {
			accuracy = 10,
			speed_caret = 10
		}
	},
	-- Любит прокачку
	accuracy = {
		favorite_artifacts = {"speed_caret", "accuracy"},
		counts_step = {
			trap = {0,0},
			catch = {0,1},
			speed_caret = {1,2},
			accuracy = {1,2},
			bank = {1,2},
			try = {0,0},
		},
		characteristics_step = {
			accuracy = 1,
			speed_caret = 1
		}
	},

	-- Обычный
	default = {
		favorite_artifacts = {"speed_caret", "accuracy", "bank"},
		counts_step = {
			trap = {1,2},
			catch = {1,2},
			speed_caret = {1,2},
			accuracy = {1,2},
			bank = {1,2},
			try = {0,1},
		},
		characteristics_step = {
			accuracy = 2,
			speed_caret = 2
		}
	},
	-- Любит банки
	random = {},
}

return M