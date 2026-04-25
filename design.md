# design.md

## name: SurvivAI Inclusion System
**colors:**
  - **surface:** '#FFF8E1'
  - **surface-dim:** '#F5F0DB'
  - **surface-bright:** '#FFFFFF'
  - **surface-container-lowest:** '#FFFFFF'
  - **surface-container-low:** '#FFFBF0'
  - **surface-container:** '#FFF8E1'
  - **surface-container-high:** '#F8F1D5'
  - **surface-container-highest:** '#EFDEC0'
  - **on-surface:** '#1A1A1A'
  - **on-surface-variant:** '#4A4A4A'
  - **outline:** '#FFD54F'
  - **outline-variant:** '#E0C040'
  - **primary:** '#0066FF'
  - **on-primary:** '#FFFFFF'
  - **primary-container:** '#E6F0FF'
  - **on-primary-container:** '#004BB3'
  - **secondary:** '#FFD54F'
  - **on-secondary:** '#0066FF'
  - **secondary-container:** '#FFF2CC'
  - **on-secondary-container:** '#B38F00'
  - **error:** '#FF4D4D'
  - **on-error:** '#FFFFFF'
  - **background:** '#F9FAFB'
  - **on-background:** '#1A1A1A'

**typography:**
  - **headline-xl:**
    - fontFamily: Outfit
    - fontSize: 40px
    - fontWeight: '800'
    - lineHeight: '1.1'
    - letterSpacing: -0.04em
  - **headline-lg:**
    - fontFamily: Outfit
    - fontSize: 32px
    - fontWeight: '700'
    - lineHeight: '1.2'
    - letterSpacing: -0.02em
  - **headline-md:**
    - fontFamily: Outfit
    - fontSize: 24px
    - fontWeight: '700'
    - lineHeight: '1.2'
  - **body-bold:**
    - fontFamily: Inter
    - fontSize: 16px
    - fontWeight: '700'
    - lineHeight: '1.5'
  - **body-base:**
    - fontFamily: Inter
    - fontSize: 14px
    - fontWeight: '500'
    - lineHeight: '1.6'
  - **label-caps:**
    - fontFamily: Outfit
    - fontSize: 10px
    - fontWeight: '900'
    - lineHeight: '1.0'
    - letterSpacing: 0.3em

**spacing:**
  - **unit:** 4px
  - **gutter:** 16px
  - **margin:** 20px
  - **radius-xl:** 40px
  - **radius-lg:** 24px

---

## Brand & Style

The **SurvivAI** design system adopts the **WARGA** philosophy of **Organic Fluidity** to transform financial stress into proactive management. For credit-invisible users like Siti, the UI acts as a "digital sanctuary," using ultra-large border-radii and soft-brutalism to remove the intimidation of traditional banking. The interface replaces rigid grids with floating modular containers that simulate a protective, companion-like experience.

## Colors

The palette leverages the **Warga Blue (#0066FF)** to provide a foundation of institutional trust, while **Warga Gold (#FFD54F)** highlights the "Lifeline" features. The **Soft Yellow (#FFF8E1)** canvas is critical for SurvivAI, as it reduces the high-contrast "alert fatigue" often associated with low-balance warnings.

* **Survival Blue:** Used for the primary countdown header to anchor the user's focus on their runway.
* **Emergency Gold:** Reserved for the Emergency Mode activation and the Emergency Credit Lifeline (ECL) CTA.
* **Category Green:** Applied to "Essential" transaction tags (Groceries, Utilities) to signal safe spending.

## Typography

The strategy focuses on **Numerical Impact** to make abstract financial data feel tangible.

* **Runway Visualization:** The "Survival Days" count is set in **Headline-XL** with -0.04em tracking, making the number the most dominant visual element on the screen.
* **Semantic Tagging:** Transaction categories (Essential/Discretionary) use the **Label-Caps** style with wide letter spacing, creating clear boundaries for AI-driven classification without using harsh dividers.

## Layout & Spacing

Following the **Modular Floating Stack** approach, the SurvivAI interface is a series of decoupled components.

* **Fluid Crisis Header:** The Emergency Mode dashboard utilizes a 64px bottom radius, creating a downward flow that leads Siti directly to her survival countdown.
* **Pill-Like Modules:** The ECL application and spending breakdown cards use **Radius-XL (40px)** to maintain a soft, non-punitive aesthetic even when discussing debt or budget cuts.
* **The Gold Connector:** A vertical gold stroke connects the "Days Remaining" card to the "Apply for Lifeline" module, visually guiding the user from a problem to a solution.

## Elevation & Depth

Depth is used to establish a hierarchy of "Protective Priority."

1.  **Ambient Lift:** Main survival modules feature a 40px blur shadow (`#0066FF` at 5% opacity) to "lift" them off the yellow background, suggesting they are actionable tools, not static text.
2.  **Safety Glass:** AI Nudges use a backdrop-blur effect (10% white fill) to appear as floating, lightweight advice rather than intrusive alerts.
3.  **Active Touch:** The "Emergency Mode" toggle and "Accept Loan" buttons use 2D shadows to provide a high-trust tactile invitation.

## Shapes

The shape language is strictly **Circular and Super-Rounded** to eliminate the "sharp edges" of financial fragility.

* **The Baseline:** All secondary cards and transaction blocks adhere to a **40px (2.5rem)** radius.
* **Restricted Pill:** The MCC-locked sub-balance on the TNG Visa Card is represented by a "super-ellipse" card and full-rounded status indicators for merchant categories.
* **Liquid UI:** UI elements use organic cutouts to simulate a liquid state that "fills" the mobile frame, making the app feel like a custom-fit tool for the user’s specific life journey.