---
name: tailwind-design-system
description: Use when building a design system with Tailwind CSS — establishing tokens, component patterns, and consistent styling conventions. Invoke when setting up Tailwind for a project, creating reusable styled components, or asked to "build a design system with Tailwind" or "make Tailwind consistent across the project".
---

# Tailwind Design System

## Overview

Build a consistent, maintainable design system using Tailwind CSS.

**Core principle:** Design tokens in `tailwind.config.js`, not inline class lists. Consistency requires a single source of truth.

---

## Project Setup

### tailwind.config.js — The Design Token Source

```javascript
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./src/**/*.{ts,tsx,js,jsx}'],
  theme: {
    // Override defaults (replace)
    colors: {
      transparent: 'transparent',
      current: 'currentColor',
    },
    extend: {
      // Extend defaults (add to)
      colors: {
        brand: {
          50:  '#eff6ff',
          500: '#3b82f6',
          900: '#1e3a5f',
        },
        surface: {
          DEFAULT: '#ffffff',
          raised: '#f8fafc',
          overlay: '#f1f5f9',
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        mono: ['JetBrains Mono', 'monospace'],
      },
      fontSize: {
        'xs': ['0.75rem', { lineHeight: '1rem' }],
        'sm': ['0.875rem', { lineHeight: '1.25rem' }],
        'base': ['1rem', { lineHeight: '1.5rem' }],
        'lg': ['1.125rem', { lineHeight: '1.75rem' }],
        'xl': ['1.25rem', { lineHeight: '1.75rem' }],
        '2xl': ['1.5rem', { lineHeight: '2rem' }],
      },
      spacing: {
        '18': '4.5rem',
        '22': '5.5rem',
      },
      borderRadius: {
        'sm': '0.25rem',
        DEFAULT: '0.375rem',
        'md': '0.5rem',
        'lg': '0.75rem',
        'xl': '1rem',
      },
      boxShadow: {
        'sm': '0 1px 2px 0 rgb(0 0 0 / 0.05)',
        DEFAULT: '0 1px 3px 0 rgb(0 0 0 / 0.1)',
        'md': '0 4px 6px -1px rgb(0 0 0 / 0.1)',
        'lg': '0 10px 15px -3px rgb(0 0 0 / 0.1)',
      },
    },
  },
  plugins: [],
}
```

---

## Component Patterns

### Use `cn()` for Conditional Classes

```typescript
import { clsx, type ClassValue } from 'clsx'
import { twMerge } from 'tailwind-merge'

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

// Usage
<Button className={cn(
  "px-4 py-2 rounded font-medium",
  variant === 'primary' && "bg-brand-500 text-white",
  variant === 'secondary' && "bg-surface-raised border border-gray-200",
  disabled && "opacity-50 cursor-not-allowed"
)} />
```

### Variant Pattern with CVA

```typescript
import { cva, type VariantProps } from 'class-variance-authority'

const buttonVariants = cva(
  // Base classes (always applied)
  "inline-flex items-center justify-center rounded font-medium transition-colors focus-visible:outline-none focus-visible:ring-2",
  {
    variants: {
      variant: {
        primary: "bg-brand-500 text-white hover:bg-brand-600",
        secondary: "bg-surface-raised border border-gray-200 hover:bg-surface-overlay",
        ghost: "hover:bg-surface-raised",
        destructive: "bg-red-500 text-white hover:bg-red-600",
      },
      size: {
        sm: "h-8 px-3 text-sm",
        md: "h-10 px-4 text-sm",
        lg: "h-12 px-6 text-base",
      },
    },
    defaultVariants: {
      variant: "primary",
      size: "md",
    },
  }
)

interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {}

export function Button({ variant, size, className, ...props }: ButtonProps) {
  return <button className={cn(buttonVariants({ variant, size }), className)} {...props} />
}
```

---

## Avoiding Class Sprawl

**The Problem:** Long inline class lists become unmaintainable:

```tsx
// ❌ Hard to read, modify, and review
<div className="flex flex-col gap-4 p-6 bg-white rounded-lg border border-gray-200 shadow-sm hover:shadow-md transition-shadow duration-200 cursor-pointer">
```

**Solutions:**

```tsx
// ✅ Extract to a component
export function Card({ children, className }: CardProps) {
  return (
    <div className={cn("flex flex-col gap-4 p-6 bg-white rounded-lg border border-gray-200 shadow-sm hover:shadow-md transition-shadow duration-200 cursor-pointer", className)}>
      {children}
    </div>
  )
}

// ✅ Or use @apply in a CSS file (for truly global patterns)
/* globals.css */
@layer components {
  .card-base {
    @apply flex flex-col gap-4 p-6 bg-white rounded-lg border border-gray-200;
  }
}
```

---

## Design System Checklist

- [ ] `tailwind.config.js` has brand colors defined as design tokens
- [ ] No hardcoded hex values in className strings
- [ ] `cn()` helper function available for conditional classes
- [ ] Base components (Button, Input, Card) use CVA variant pattern
- [ ] All interactive elements have focus-visible styles
- [ ] Dark mode configured if needed: `darkMode: 'class'` in config
- [ ] `tailwind-merge` installed to handle class conflicts in `cn()`

---

## Hard Rules

- **Design tokens in `tailwind.config.js`, not in classes.** `bg-brand-500` not `bg-[#3b82f6]`.
- **Never `!important` or `style={{}}` for layout.** If Tailwind can't express it, add a token.
- **`twMerge` for all class merging.** Raw string concatenation breaks Tailwind's merge resolution.
- **Extract components, not class groups.** If you copy the same 10 classes twice, make a component.
