
#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table -t -A -c"

# Check if an argument was provided
if [ -z "$1" ]
then
  echo "Please provide an element as an argument."
  exit 0
fi

INPUT=$(printf '%s' "$1" | sed "s/'/''/g")

# Determine whether input is a number or text
case "$1" in
  *[!0-9]*)
    CONDITION="e.symbol = '$INPUT' OR e.name = '$INPUT'"
    ;;
  *)
    CONDITION="e.atomic_number = $1"
    ;;
esac

# Find the requested element
ELEMENT=$($PSQL "
SELECT
  e.atomic_number,
  e.name,
  e.symbol,
  t.type,
  p.atomic_mass,
  p.melting_point_celsius,
  p.boiling_point_celsius
FROM elements e
JOIN properties p
  ON e.atomic_number = p.atomic_number
JOIN types t
  ON p.type_id = t.type_id
WHERE $CONDITION
LIMIT 1;
")

# Check if the element exists
if [ -z "$ELEMENT" ]
then
  echo "I could not find that element in the database."
  exit 0
fi

# Display element information
printf '%s\n' "$ELEMENT" |
while IFS='|' read -r NUMBER NAME SYMBOL TYPE MASS MELTING BOILING
do
  printf "The element with atomic number %s is %s (%s). It's a %s, with a mass of %s amu. %s has a melting point of %s celsius and a boiling point of %s celsius.\n" \
    "$NUMBER" "$NAME" "$SYMBOL" "$TYPE" "$MASS" "$NAME" "$MELTING" "$BOILING"
done

exit 0
