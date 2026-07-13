# Google Play Store Listing — Craft Discount Liquors

Ready-to-paste content for Play Console. Character limits are noted; the copy
below already fits. Replace the **[BRACKETED]** placeholders with your real info.

---

## 1. App details

| Field | Value |
|-------|-------|
| App name (max 30) | `Craft Discount Liquors` |
| Default language | English (United States) – `en-US` |
| App or game | App |
| Free or paid | Free (the app is free; users pay for products) |
| Package name | `com.vadiyatech.craftdiscountliquors` |
| Category | Shopping |
| Tags | alcohol delivery, shopping, grocery (pick from Play's tag list) |

---

## 2. Short description (max 80 characters)

Use one of these (all under 80 chars):

```
Wine, beer & spirits delivered fast. Shop deals & track your order in-app.
```

Alternatives:
```
Shop wine, beer & spirits at discount prices — fast local delivery to you.
```
```
Your local liquor store, delivered. Browse deals, order & track in minutes.
```

---

## 3. Full description (max 4000 characters)

```
Craft Discount Liquors brings your favorite wine, beer, and spirits straight to your door. Browse a huge selection at discount prices, order in a few taps, and track your delivery in real time — all from one easy app.

You must be 21 or older to use this app. Valid government-issued ID is required at delivery.

WHY YOU'LL LOVE IT

• Huge selection — Explore wine, beer, whiskey, vodka, tequila, and more across easy-to-browse categories.
• Discount prices & deals — Shop flash deals, featured products, and daily offers to save on every order.
• Fast local delivery — Get your order delivered to your door, with live order tracking on the map.
• Easy reordering — Save your favorites and reorder in seconds.
• Secure checkout — Pay safely with multiple payment options and apply coupon codes at checkout.
• Wallet & loyalty rewards — Earn loyalty points on purchases and use your in-app wallet for faster checkout.
• Refer & earn — Invite friends and earn rewards when they order.
• Order history & reviews — Track past orders and rate the products you love.
• Multiple addresses — Save home, work, and more for quick delivery.
• Real-time support — Chat with our support team right inside the app.
• English & Spanish — Use the app in your preferred language.

HOW IT WORKS

1. Create your account and verify you're 21+.
2. Browse categories or search for exactly what you want.
3. Add to cart, apply any coupons, and check out.
4. Track your delivery in real time and have ID ready at the door.

RESPONSIBLE DELIVERY

We are committed to the responsible sale of alcohol. Orders are only delivered to customers who are 21 years of age or older and who can present a valid government-issued photo ID at the time of delivery. Delivery is available only in areas where we are licensed to operate.

Download Craft Discount Liquors today and enjoy great prices, fast delivery, and a smarter way to shop for wine, beer, and spirits.

Please drink responsibly.
```

> Tip: keep the "21 or older" and "valid ID" lines near the top — Play reviewers
> look for an explicit age/compliance statement on alcohol apps.

---

## 4. Graphic assets (you must supply these — current ones are the GroFresh template)

| Asset | Spec | Required? |
|-------|------|-----------|
| App icon | 512 × 512 px, 32-bit PNG, < 1 MB | Yes |
| Feature graphic | 1024 × 500 px, PNG/JPG (no alpha) | Yes |
| Phone screenshots | 2–8 images, PNG/JPG, 16:9 or 9:16, each side 320–3840 px | Yes (min 2) |
| 7" tablet screenshots | same format | Optional (recommended) |
| 10" tablet screenshots | same format | Optional (recommended) |
| Promo video | YouTube URL | Optional |

Screenshot ideas (capture from a release build): home/deals, a category list,
product detail, cart/checkout, live order tracking, wallet & loyalty.

---

## 5. Store settings / contact details

| Field | Value |
|-------|-------|
| Email (shown publicly, required) | `[YOUR SUPPORT EMAIL]` |
| Phone (optional) | `[YOUR SUPPORT PHONE]` |
| Website | `https://craftdiscountliquors.com` (or your public site) |
| **Privacy policy URL (REQUIRED)** | `[https://...your privacy policy]` |

A privacy policy is mandatory and must be a live, public URL before you can
submit. It must disclose what data you collect (account info, location,
purchase history) and how it's used.

---

## 6. Content rating questionnaire (IARC)

Answer honestly. Key answers for this app:

- App category: **Reference, News, or Educational? → No.** Choose the standard
  questionnaire for a Shopping/utility app.
- Does the app contain or reference **alcohol, tobacco, or drugs?** → **YES –
  references and facilitates the purchase of alcohol.**
- Violence / sexual content / gambling / profanity → **No** (unless you add any).
- Result: expect a **Mature / 18+ (PEGI 18, ESRB Mature, USK 18)** rating because
  of alcohol sales. This is normal and required.

---

## 7. Target audience & content

- Target age group: **18+ only** (do NOT include any under-18 bracket — alcohol
  apps must exclude minors).
- "Appeal to children" → **No.**

---

## 8. Data safety form (required)

Declare what the app actually collects. For this app, typical answers:

**Data collected & shared:**
- Personal info: name, email address, phone number, physical address → collected
  (for account + delivery). Shared with delivery/payment providers as needed.
- Location: approximate & precise location → collected (delivery address, order
  tracking).
- Financial info: purchase history → collected. (Payment card data is handled by
  your payment processor — confirm whether the app sees it.)
- App activity / app info & performance → collected for analytics (Firebase).
- Device IDs → collected (push notifications, analytics; iOS uses ATT tracking).

**For each type, set:**
- Collected: Yes
- Shared: Yes/No depending on third parties (payment, delivery, analytics)
- Processed ephemerally: usually No
- Required or optional: mostly required for core function
- Encrypted in transit: **Yes** (your API is HTTPS)
- User can request deletion: **Yes** — the app has a "remove account" feature
  (`/api/v1/customer/remove-account`). Provide a deletion method/URL.

---

## 9. App access (for reviewers)

The app requires login and is age-gated, so reviewers can't see it without help.
In **App content → App access**, provide:
- A working **demo account** (username + password).
- A **delivery address inside your service area** so the reviewer can reach
  checkout.
- A note: "Alcohol delivery app. Account requires 21+ age confirmation. Use the
  provided test address which is within our licensed delivery zone."

---

## 10. Other declarations (App content section)

- Ads: declare whether the app shows ads (this app: **No** unless you added them).
- Government app: No.
- COVID-19 contact tracing/status: No.
- Financial features: No (unless your wallet qualifies — generally No).
- Data deletion: provide the in-app account deletion path + a web URL if asked.

---

## 11. Alcohol policy compliance (read this — top rejection cause)

Google Play allows alcohol-commerce apps but enforces them strictly:

- The app **must verify users are of legal drinking age** (21+ in the US) — an
  age gate at signup or checkout. Make sure this exists and mention it in review
  notes.
- Delivery must **require ID verification** at the door — state this in your
  listing and review notes.
- **Restrict distribution** (Play Console → Production → Countries/regions) to
  only the countries/states where you are licensed to sell and deliver alcohol.
- Don't market to minors; the description must not appeal to people under 21.
- Some regions require you to hold (and be able to show) a valid alcohol license.

---

## 12. Step-by-step submission

1. Pay the **$25 one-time** Google Play Developer registration fee and verify
   your identity/organization (this can take a few days — start early).
2. **Create app** in Play Console → name, default language, App, Free.
3. Complete **Store listing** (sections 1–5 above) and upload graphics.
4. Complete **App content**: privacy policy, app access (demo account), ads,
   content rating, target audience, data safety, government/financial
   declarations.
5. **Set up your release:**
   - Play App Signing: **enroll** (recommended). You upload with your upload key
     (`upload-keystore.jks`); Google manages the final app signing key.
   - Upload the bundle: `build/app/outputs/bundle/release/app-release.aab`
     (already built and signed).
6. Pick a track: start with **Internal testing** (instant, up to 100 testers) to
   sanity-check, then promote to **Production**.
7. In **Production → Countries/regions**, restrict to your licensed areas.
8. Submit for review. First reviews for a new account can take a few days to
   ~2 weeks; alcohol apps may get extra scrutiny.

---

## 13. Build & version commands

```bash
# Build the upload bundle (already done once)
flutter build appbundle --release
# -> build/app/outputs/bundle/release/app-release.aab

# For each future update, bump the version in pubspec.yaml first:
#   version: 1.0.0+1   ->   1.0.1+2
# The build number after '+' MUST increase on every upload.
```

---

## Still blocking a real submission (from RELEASE_CHECKLIST.md)

- App branding is still the GroFresh template (icon + in-app logos) — replace
  before submitting or risk rejection.
- Google Maps API key, Facebook login, and Google Sign-In are placeholders —
  configure or remove the broken buttons.
- A live privacy policy URL must exist.
- Age-verification flow must be in place for alcohol compliance.
