// const require = createRequire(import.meta.url)

/** @type {import('tailwindcss').Config} */
export default {
	content: ["./src/**/*.{html,js,svelte,ts}"],
	theme: {
		extend: {
			borderRadius: {
				DEFAULT: "2px"
			},
			container: () => ({
				center: true,
				screens: {
					lg: "1440px"
				},
				padding: {
					DEFAULT: "0.725rem",
					sm: "1rem",
					lg: "1.125rem"
				}
			}),
			colors: ({ colors }) => ({
				brand: "#7f3f98",
				"brand-light": "#9b52b7",
				"brand-dark": "#613074",
				"base-1": "#18181B",
				"base-2": "#1D1D20",
				"base-3": "#202023",
				copy: colors.neutral[50],
				"copy-light": colors.neutral[300],
				"copy-lighter": colors.neutral[600],
				success: "#3f983f",
				warning: "#98983f",
				error: "#983f3f",
				"success-content": "#e3f3e3",
				"warning-content": "#000000",
				"error-content": "#f3e3e3",
				"github-dark": "#171515",
				"facebook-blue": "#3975EA",
				"whatsapp-green": "#6EC464"
			})
		},
		scale: {
			102: "1.02"
		},
		fontFamily: {
			display: ["Raleway", "sans-serif"],
			sans: ["Manrope", "sans-serif"]
		}
	},
	plugins: [require("@tailwindcss/forms")]
};
