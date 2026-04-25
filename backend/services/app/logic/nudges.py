def build_nudge(language: str, category: str, amount_7d: float, days_gain: int) -> str:
    if language.lower() == "bm":
        return (
            f"Anda membelanjakan RM{amount_7d:.2f} untuk {category} minggu ini. "
            f"Kurangkan sedikit = +{days_gain} hari bertahan."
        )

    return (
        f"You spent RM{amount_7d:.2f} on {category} this week. "
        f"Cut a little = +{days_gain} survival days."
    )
