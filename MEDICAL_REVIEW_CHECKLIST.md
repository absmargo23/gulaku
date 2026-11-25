# Medical review checklist

This app must be reviewed by a qualified diabetes-care professional before clinical use. Confirm the wording and intended audience of each item below.

## Glucose thresholds and classification

- [ ] Confirm the default mg/dL ranges: low `<70`, normal `70–180`, caution `181–250`, and high `>250`.
- [ ] Confirm boundary handling at 70, 180, and 250 mg/dL and the display labels “Rendah”, “Normal”, “Waspada”, and “Tinggi”.
- [ ] Confirm the supported input range of 20–600 mg/dL and the invalid-value messages.
- [ ] Confirm that users can configure the target range without implying an individualized treatment target.
- [ ] Confirm that trend charts, time-in-range summaries, status labels, and reminders are not presented as diagnosis or treatment advice.

## Low-glucose instructions

- [ ] Review the suggested instruction to consume about 15 grams of fast-acting sugar and recheck in 15 minutes.
- [ ] Review the examples (“3 sendok teh gula” or “setengah gelas jus”), portion sizes, and local terminology.
- [ ] Confirm that this general instruction is appropriate for the intended users and identify any situations requiring different instructions.
- [ ] Confirm whether the app should include additional emergency guidance for severe symptoms or inability to swallow.
- [ ] Confirm that the user should follow their clinician-provided plan when it differs from the app wording.
- [ ] Confirm the wording and placement of “Hubungi keluarga” and “Hubungi dokter” and the handling of phone numbers configured by the user.

## Estimated HbA1c

- [ ] Review the estimate formula `(average glucose + 46.7) / 28.7`.
- [ ] Confirm the limitations of deriving an estimated HbA1c from the available readings and the minimum data needed for a meaningful estimate.
- [ ] Confirm that every estimate is labeled “perkiraan” and is not represented as a laboratory result or diagnosis.

## Nutrition and medication safety

- [ ] Review the carbohydrate estimates for suggested Indonesian foods, portions, and the “perkiraan” label.
- [ ] Confirm that food logging does not imply medication or insulin dosing guidance.
- [ ] Confirm reminder wording does not expose medication names or glucose values on the lock screen.
- [ ] Confirm no screen, report, or notification gives insulin or medication dosing advice.

## Reports, consent, and disclaimers

- [ ] Review the doctor-facing report fields, ranges, charts, and “Waktu dalam rentang” summary.
- [ ] Confirm the disclaimer “Aplikasi ini bukan pengganti saran dokter.” is visible where appropriate.
- [ ] Confirm that report sharing and any future family-data sharing require clear, explicit consent.
- [ ] Confirm family mode shares only the minimum status-alert information by default, never the full history without separate consent.
- [ ] Review Indonesian wording, accessibility, and the intended health literacy level.
