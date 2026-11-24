// Design tokens from spec section 13.1. Components use these names
// (bg-brand, text-muted, ...) and never raw hex values.
/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,jsx}'],
  theme: {
    extend: {
      colors: {
        brand: { DEFAULT: '#1F7A4D', dark: '#145A38', soft: '#E6F4EC' },
        accent: { DEFAULT: '#F5A524', soft: '#FEF3DC' },
        berry: '#C2255C',
        ink: '#1C1917',
        muted: '#57534E',
        line: '#E7E5E4',
        surface: '#FFFFFF',
        canvas: '#FAFAF7',
        success: '#15803D',
        warning: '#B45309',
        danger: '#B91C1C',
        info: '#1D4ED8',
      },
      fontFamily: {
        heading: ['"Plus Jakarta Sans"', 'sans-serif'],
        sans: ['Inter', 'sans-serif'],
      },
      borderRadius: {
        input: '8px',
        card: '12px',
        hero: '20px',
      },
      boxShadow: {
        card: '0 1px 2px rgba(0,0,0,.06)',
        modal: '0 8px 24px rgba(0,0,0,.08)',
      },
    },
  },
  plugins: [],
};
