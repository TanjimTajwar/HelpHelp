// Educational estimate only. Real cases require qualified Islamic scholarship.

class InheritanceLine {
  const InheritanceLine({
    required this.label,
    required this.amount,
    this.detail,
  });

  final String label;
  final double amount;
  final String? detail;
}

class InheritanceOutcome {
  const InheritanceOutcome({
    required this.estate,
    required this.lines,
    required this.unallocated,
    this.warning,
  });

  final double estate;
  final List<InheritanceLine> lines;
  final double unallocated;
  final String? warning;
}

enum SpouseMode { none, husband, wives }

/// Simplified Sunni-style model for common teaching scenarios:
/// — Spouse + descendants: standard Qur'anic fractions for spouse/parents.
/// — With sons: daughters share residue with sons at 1:2 per capita (not fixed 2/3).
/// — Daughters only (no sons): fixed 1/2 or 2/3 of the estate together with other fixed shares; awl if total > 100%.
/// — Without descendants: only rough spouse-only shares; parents without children not allocated here.
InheritanceOutcome computeInheritance({
  required double estate,
  required int sons,
  required int daughters,
  required bool fatherAlive,
  required bool motherAlive,
  required SpouseMode spouseMode,
  required int wifeCount,
}) {
  if (estate <= 0) {
    return const InheritanceOutcome(estate: 0, lines: [], unallocated: 0);
  }

  final hasDescendants = sons > 0 || daughters > 0;
  final w = wifeCount.clamp(0, 4);

  if (spouseMode == SpouseMode.husband && w > 0) {
    return InheritanceOutcome(
      estate: estate,
      lines: const [],
      unallocated: estate,
      warning:
          'Invalid: a deceased cannot leave both a husband and wives in this calculator.',
    );
  }

  if (spouseMode == SpouseMode.wives && (w < 1 || w > 4)) {
    return InheritanceOutcome(
      estate: estate,
      lines: const [],
      unallocated: estate,
      warning: 'Enter 1–4 wives, or choose another spouse mode.',
    );
  }

  if (!hasDescendants && (fatherAlive || motherAlive)) {
    return InheritanceOutcome(
      estate: estate,
      lines: const [],
      unallocated: estate,
      warning:
          'Shares for parents when there are no children (and other special cases) are not modeled here. Consult a scholar.',
    );
  }

  if (!hasDescendants) {
    return _spouseOnly(estate: estate, spouseMode: spouseMode, wifeCount: w);
  }

  if (sons > 0) {
    return _withSons(
      estate: estate,
      sons: sons,
      daughters: daughters,
      fatherAlive: fatherAlive,
      motherAlive: motherAlive,
      spouseMode: spouseMode,
      wifeCount: w,
    );
  }

  return _daughtersOnlyNoSons(
    estate: estate,
    daughters: daughters,
    fatherAlive: fatherAlive,
    motherAlive: motherAlive,
    spouseMode: spouseMode,
    wifeCount: w,
  );
}

InheritanceOutcome _spouseOnly({
  required double estate,
  required SpouseMode spouseMode,
  required int wifeCount,
}) {
  final lines = <InheritanceLine>[];
  switch (spouseMode) {
    case SpouseMode.husband:
      lines.add(
        InheritanceLine(
          label: 'Husband',
          amount: estate * 0.5,
        ),
      );
      return InheritanceOutcome(estate: estate, lines: lines, unallocated: estate * 0.5);
    case SpouseMode.wives:
      final total = estate * 0.25;
      final each = total / wifeCount;
      lines.add(
        InheritanceLine(
          label: 'Wife share (total)',
          amount: total,
          detail: wifeCount > 1 ? '$wifeCount wives × ${each.toStringAsFixed(2)} each' : null,
        ),
      );
      return InheritanceOutcome(estate: estate, lines: lines, unallocated: estate - total);
    case SpouseMode.none:
      return InheritanceOutcome(
        estate: estate,
        lines: const [],
        unallocated: estate,
        warning:
            'No descendants and no spouse selected — full distribution is not modeled.',
      );
  }
}

double _wifeTotalFraction({required bool hasDescendants}) {
  return hasDescendants ? 1 / 8 : 1 / 4;
}

double _husbandFraction({required bool hasDescendants}) {
  return hasDescendants ? 1 / 4 : 1 / 2;
}

/// Apply proportional reduction ('awl) when fixed shares sum to more than the whole.
List<double> _awl(List<double> fracs) {
  final s = fracs.fold<double>(0, (a, b) => a + b);
  if (s <= 1 + 1e-12) return fracs;
  return fracs.map((f) => f / s).toList();
}

InheritanceOutcome _withSons({
  required double estate,
  required int sons,
  required int daughters,
  required bool fatherAlive,
  required bool motherAlive,
  required SpouseMode spouseMode,
  required int wifeCount,
}) {
  final lines = <InheritanceLine>[];
  final hasDescendants = true;

  double hFrac = 0;
  double wTotalFrac = 0;
  double fFrac = fatherAlive ? 1 / 6 : 0.0;
  double mFrac = motherAlive ? 1 / 6 : 0.0;

  if (spouseMode == SpouseMode.husband) {
    hFrac = _husbandFraction(hasDescendants: hasDescendants);
  } else if (spouseMode == SpouseMode.wives && wifeCount > 0) {
    wTotalFrac = _wifeTotalFraction(hasDescendants: hasDescendants);
  }

  final raw = <double>[hFrac, wTotalFrac, fFrac, mFrac];
  final adjusted = _awl(raw);
  hFrac = adjusted[0];
  wTotalFrac = adjusted[1];
  fFrac = adjusted[2];
  mFrac = adjusted[3];

  var remaining = estate;
  if (spouseMode == SpouseMode.husband && hFrac > 0) {
    final a = estate * hFrac;
    lines.add(InheritanceLine(label: 'Husband', amount: a));
    remaining -= a;
  }
  if (spouseMode == SpouseMode.wives && wifeCount > 0 && wTotalFrac > 0) {
    final total = estate * wTotalFrac;
    final each = total / wifeCount;
    lines.add(
      InheritanceLine(
        label: 'Wives (total)',
        amount: total,
        detail: wifeCount > 1 ? '$wifeCount × ${each.toStringAsFixed(2)} each' : null,
      ),
    );
    remaining -= total;
  }
  if (fatherAlive && fFrac > 0) {
    final a = estate * fFrac;
    lines.add(InheritanceLine(label: 'Father', amount: a));
    remaining -= a;
  }
  if (motherAlive && mFrac > 0) {
    final a = estate * mFrac;
    lines.add(InheritanceLine(label: 'Mother', amount: a));
    remaining -= a;
  }

  if (remaining < -1e-6) {
    remaining = 0;
  }

  final parts = 2 * sons + daughters;
  if (parts <= 0) {
    return InheritanceOutcome(
      estate: estate,
      lines: lines,
      unallocated: remaining,
      warning: 'Enter at least one child.',
    );
  }

  final perFemale = remaining / parts;
  final perMale = 2 * perFemale;
  lines.add(
    InheritanceLine(
      label: 'Sons (total)',
      amount: perMale * sons,
      detail: sons > 1 ? '$sons × ${perMale.toStringAsFixed(2)} each' : null,
    ),
  );
  if (daughters > 0) {
    lines.add(
      InheritanceLine(
        label: 'Daughters (total)',
        amount: perFemale * daughters,
        detail: daughters > 1 ? '$daughters × ${perFemale.toStringAsFixed(2)} each' : null,
      ),
    );
  }

  final allocated = lines.fold<double>(0, (s, e) => s + e.amount);
  final unalloc = estate - allocated;
  return InheritanceOutcome(
    estate: estate,
    lines: lines,
    unallocated: unalloc.abs() < 0.01 ? 0 : unalloc,
  );
}

InheritanceOutcome _daughtersOnlyNoSons({
  required double estate,
  required int daughters,
  required bool fatherAlive,
  required bool motherAlive,
  required SpouseMode spouseMode,
  required int wifeCount,
}) {
  if (daughters <= 0) {
    return InheritanceOutcome(
      estate: estate,
      lines: const [],
      unallocated: estate,
      warning: 'No sons and no daughters — check inputs.',
    );
  }

  final dShareTotal = daughters == 1 ? 0.5 : 2.0 / 3.0;

  double hFrac = 0;
  double wTotalFrac = 0;
  if (spouseMode == SpouseMode.husband) {
    hFrac = _husbandFraction(hasDescendants: true);
  } else if (spouseMode == SpouseMode.wives && wifeCount > 0) {
    wTotalFrac = _wifeTotalFraction(hasDescendants: true);
  }

  double fFrac = fatherAlive ? 1 / 6 : 0.0;
  double mFrac = motherAlive ? 1 / 6 : 0.0;

  final raw = <double>[hFrac, wTotalFrac, fFrac, mFrac, dShareTotal];
  final adj = _awl(raw);
  hFrac = adj[0];
  wTotalFrac = adj[1];
  fFrac = adj[2];
  mFrac = adj[3];
  final dFrac = adj[4];

  final lines = <InheritanceLine>[];
  if (spouseMode == SpouseMode.husband && hFrac > 0) {
    lines.add(InheritanceLine(label: 'Husband', amount: estate * hFrac));
  }
  if (spouseMode == SpouseMode.wives && wifeCount > 0 && wTotalFrac > 0) {
    final total = estate * wTotalFrac;
    final each = total / wifeCount;
    lines.add(
      InheritanceLine(
        label: 'Wives (total)',
        amount: total,
        detail: wifeCount > 1 ? '$wifeCount × ${each.toStringAsFixed(2)} each' : null,
      ),
    );
  }
  if (fatherAlive && fFrac > 0) {
    lines.add(InheritanceLine(label: 'Father', amount: estate * fFrac));
  }
  if (motherAlive && mFrac > 0) {
    lines.add(InheritanceLine(label: 'Mother', amount: estate * mFrac));
  }

  final dTotal = estate * dFrac;
  final eachD = dTotal / daughters;
  lines.add(
    InheritanceLine(
      label: 'Daughters (total)',
      amount: dTotal,
      detail: daughters > 1 ? '$daughters × ${eachD.toStringAsFixed(2)} each' : null,
    ),
  );

  final allocated = lines.fold<double>(0, (s, e) => s + e.amount);
  final unalloc = estate - allocated;
  return InheritanceOutcome(
    estate: estate,
    lines: lines,
    unallocated: unalloc.abs() < 0.01 ? 0 : unalloc,
    warning: unalloc > 0.01
        ? 'Remainder may go to other heirs (e.g. siblings) or follow further rules — not modeled here.'
        : null,
  );
}
