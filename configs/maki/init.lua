maki.setup({
	-- Autonomous execution: skips interactive prompts across gated tools
	always_yolo = true,

	-- Reasoning / extended thinking level for new sessions
	-- Valid options: "adaptive", "minimal", "low", "medium", "high", "max", or integer budget
	always_thinking = "adaptive",

	-- Workflow mode: allows code_execution to dispatch tasks/subagents
	always_workflow = true,

	-- Agent context accounting and execution limits
	agent = {
		rtk = true, -- Uses rtk to filter bash noise (~50% token reduction)
		stale_read_check = true, -- Prevents race conditions and blind overwrites
		compaction_buffer = "15%", -- Reserved headroom before running context compaction
		max_output_lines = 2000,
		max_continuation_turns = 10,
	},

	-- Plugin toggles & tool options
	plugins = {
		edit = {
			edit_lines = true,
		},
		task = {
			max_concurrent = 32,
		},
		code_execution = {
			enabled = true,
		},
	},
})
