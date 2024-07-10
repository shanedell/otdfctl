---
title: Unsafe changes to attribute namespaces
command:
  name: unsafe
  flags:
    - name: force
      description: Force unsafe change without confirmation
      required: false
---

# Unsafe Changes to Attribute Namespaces

Unsafe changes are dangerous mutations to Policy that can significantly change access behavior around existing attributes
and entitlement.

Depending on the unsafe change introduced and already existing TDFs, TDFs might become inaccessible that were previously
accessible or vice versa.

Make sure you know what you are doing.