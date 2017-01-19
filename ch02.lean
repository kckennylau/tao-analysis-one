/-------------------------------------------------------------------------------\
  solutions for chapter two: the natural numbers                                  
  analysis 1, third edition, tao                                             
\-------------------------------------------------------------------------------/

theorem succ.inj {a b : ℕ} (h : nat.succ a = nat.succ b) : a = b :=
nat.no_confusion h (λ e : a = b, e).

-- exercise 2.2.1: prove proposition 2.2.5
-- addition is associative
example (a b c : ℕ) : a + b + c = a + (b + c) :=
nat.induction_on c
  (rfl)
  (take c,
    assume ih : a + b + c = a + (b + c),
    calc
      a + b + nat.succ c = nat.succ (a + b + c)   : nat.add_succ (a + b) c
                     ... = nat.succ (a + (b + c)) : congr_arg nat.succ ih
                     ... = a + (b + nat.succ c)   : nat.add_succ a (b + c)).

-- exercise 2.2.2: prove lemma 2.2.10
example (a b : ℕ) : a = 0 ∨ ∃! b, nat.succ b = a :=
nat.cases_on a
  (or.inl (eq.refl nat.zero))
  (take a : ℕ,
    suffices ∃! b, nat.succ b = nat.succ a, from or.inr this,
    exists.intro a (and.intro (rfl) 
      (take b : ℕ,
        assume h : nat.succ b = nat.succ a,
        succ.inj h))).

-- exercise 2.2.3: prove proposition 2.2.12
-- order is reflexive
example (a : ℕ) : a ≤ a :=
  have h : a + nat.zero = a, from rfl,
  nat.le.intro h.

-- order is transitive
example (a b c : ℕ) (h1 : a ≤ b) (h2 : b ≤ c) : a ≤ c :=
nat.less_than_or_equal.induction_on h2
  (h1)
  (take c' : ℕ,
    assume h3,
    assume ih : a ≤ c',
    nat.less_than_or_equal.step ih).

-- order is antisymmetric 
example (a b : ℕ) (h1 : a ≤ b) (h2 : b ≤ a) : a = b := 
  have h3 : ∃ c, a + c = b, from nat.le.dest h1,
  have h4 : ∃ d, b + d = a, from nat.le.dest h2,
  exists.elim h3 (take c, assume h5 : a + c = b,
  exists.elim h4 (take d, assume h6 : b + d = a,
  have h7 : a + (c + d) = a + 0, from 
    calc
      a + (c + d) = a + c + d : eq.symm (add_assoc a c d) 
              ... = a         : eq.symm h5 ▸ h6
              ... = a + 0     : add_zero a,
  have h8 : c + d = 0, from add_left_cancel h7,
  have h9 : c = 0, from nat.eq_zero_of_add_eq_zero_right h8,
  have h10 : a + 0 = b, from h9 ▸ h5,
  show a = b, from h10)).

-- addition preserves order
example (a b c : ℕ) : a ≤ b ↔ a + c ≤ b + c :=
iff.intro
  (assume h : a ≤ b,
    nat.less_than_or_equal.induction_on h 
      (nat.less_than_or_equal.refl (a + c))
      (take b',
        assume h : a ≤ b',
        assume ih : a + c ≤ b' + c,
        have h2 : a + c ≤ nat.succ (b' + c), 
          from nat.less_than_or_equal.step ih,
        have h3 : a + c ≤ nat.succ b' + c, 
          begin rw -nat.succ_add at h2, exact h2 end, 
        h3))
  (assume h : a + c ≤ b + c,
    have h2 : ∃ d, a + c + d = b + c, from nat.le.dest h,
    exists.elim h2 (take d, assume h3 : a + c + d = b + c,
      have h4 : c + (a + d) = c + b, from
        calc
          c + (a + d) = a + d + c : add_comm c (a + d)
                  ... = a + c + d : by simp [add_comm d c]
                  ... = b + c     : h3
                  ... = c + b     : add_comm b c,
      have h5 : a + d = b, from add_left_cancel h4,
      nat.le.intro h5)).

example (a b : ℕ) : a < b ↔ nat.succ a ≤ b :=
iff.intro
  (assume h : a < b, h)
  (assume h : nat.succ a ≤ b, h)

example (a b : ℕ) : a < b ↔ ∃ c, b = a + c ∧ c ≠ 0 :=
iff.intro
  (assume h : a < b,
    have h2 : nat.succ a ≤ b, from h,
    have h3 : ∃ d, nat.succ a + d = b, from nat.le.dest h2,
    exists.elim h3 (take d, assume h4 : nat.succ a + d = b, 
      exists.intro (nat.succ d) 
        (and.intro 
          (show b = a + nat.succ d, from 
             calc
               b = nat.succ a + d   : eq.symm h4
             ... = nat.succ (a + d) : nat.succ_add a d
             ... = a + nat.succ d   : eq.symm (nat.add_succ a d))
          (show nat.succ d ≠ 0, from nat.succ_ne_zero d)))) 
  (assume h : ∃ c, b = a + c ∧ c ≠ 0,
    exists.elim h (take c, 
      nat.cases_on c 
        (assume h, 
          have h2 : 0 ≠ 0, from and.right h,
          absurd (rfl) h2) 
        (take c',
          assume h : b = a + nat.succ c' ∧ nat.succ c' ≠ 0,
          have h2 : b = a + nat.succ c', from and.left h, 
          have h3 : b = nat.succ a + c', from 
            calc
              b = a + nat.succ c'   : h2
            ... = nat.succ (a + c') : nat.add_succ a c'
            ... = nat.succ a + c'   : eq.symm (nat.succ_add a c'),
          suffices nat.succ a ≤ b, from this,
          suffices nat.succ a ≤ nat.succ a + c', begin rw h3, exact this end, 
          nat.le_add_right (nat.succ a) c'))).

-- exercise 2.2.4: complete the proof of proposition 2.2.13
-- trichotomy of order
example (a b : ℕ) : 0 ≤ b :=
nat.induction_on b
  (nat.le_refl 0)
  (take a',
     assume h,
     nat.less_than_or_equal.step h)

example (a b : ℕ) : a > b → nat.succ a > b := 
nat.induction_on a 
  (assume h : 0 > b, 
     have h1 : b < 0, from h, 
     have h2 : false, from iff.mp (nat.lt_zero_iff_false b) h1,
     false.elim h2)
  (take a', 
     assume ih h,
     have h2 : b < nat.succ a', from h,
     nat.lt.step h2)

example (a b : ℕ) : a = b → nat.succ a > b :=
nat.induction_on a
 (assume h,
   have h1 : 0 < 1, from nat.succ_pos 0,
   eq.rec h1 h)
 (take a',
   assume ih h,
   have h2 : nat.succ (nat.succ a') ≤ nat.succ (nat.succ a'), 
     from le_refl (nat.succ (nat.succ a')),
   have h3 : nat.succ a' < nat.succ (nat.succ a'), from h2,
   have h4 : b < nat.succ (nat.succ a'), begin rw -h, exact h3 end,
   h4)

-- exercise 2.2.5: prove proposition 2.2.14
-- principle of strong induction

section

lemma le_or_eq_of_le_succ 
  {m n : ℕ} (h1 : m ≤ nat.succ n) : m ≤ n ∨ m = nat.succ n :=
begin
  cases h1 with k h2,
  right, exact (eq.refl (nat.succ n)),
  left, assumption 
end

lemma le_zero_iff_eq_zero {n : ℕ} : n ≤ 0 ↔ n = 0 :=
begin
  apply iff.intro, 
    {intro h, 
      cases h, 
      reflexivity},
    {intro h,
      rw h}, 
end

lemma stronger_induction :
  (∀ P : ℕ → Prop, P 0 → 
  (∀ n, (∀ m, m ≤ n → P m) → P (nat.succ n)) → 
  (∀ j, (∀ k, ((k ≤ j) → P k)))) :=
begin
  intros P h1 h2 j,
  induction j with j' ih,
    intros k h3,
    assert h4 : k = 0, begin exact iff.mp le_zero_iff_eq_zero h3 end,
    rw h4,
    exact h1,
    intros k h3,
    assert h4 : k ≤ j' ∨ k = nat.succ j', 
      begin exact le_or_eq_of_le_succ h3 end,
    cases h4 with h4l h4r,
      apply ih, exact h4l,
      rw h4r,
      apply h2, exact ih
end

lemma weaken :
  (∀ P : ℕ → Prop, 
  (∀ n, (∀ m, ((m ≤ n) → P m))) → 
  (∀ n, P n)) :=
begin
  intros P h n,
  apply (h n n),
  exact le_refl n
end

proposition strong_induction :
  (∀ P : ℕ → Prop, P 0 → 
  (∀ n, (∀ m, m ≤ n → P m) → P (nat.succ n)) → 
  (∀ k, P k)) :=
begin
  intros P h1 h2,
  apply weaken,
  apply stronger_induction,
    exact h1,
    exact h2
end

end
