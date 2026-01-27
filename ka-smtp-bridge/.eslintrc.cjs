module.exports = {
	root: true,
	env: {
		node: true,
		es2022: true,
	},
	parser: "@typescript-eslint/parser",
	parserOptions: {
		ecmaVersion: "latest",
		sourceType: "module",
		project: ["./tsconfig.json"],
	},
	plugins: ["@typescript-eslint", "unused-imports", "import"],
	extends: [
		"plugin:@typescript-eslint/recommended",
		"standard-with-typescript",
		"prettier",
	],
	rules: {
		// Supprime les imports inutilisés
		"unused-imports/no-unused-imports": "warn",
		"no-console": "off",
		"@typescript-eslint/explicit-function-return-type": "off",
		"@typescript-eslint/no-misused-promises": "off",
	},
	overrides: [
		{
			files: ["*.vue"],
			parser: "vue-eslint-parser",
			parserOptions: {
				parser: "@typescript-eslint/parser",
				extraFileExtensions: [".vue"],
			},
			extends: ["plugin:vue/vue3-recommended"],
		},
	],
};
