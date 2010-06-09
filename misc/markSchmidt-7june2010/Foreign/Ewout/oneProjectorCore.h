/* oneProjectorCore.h
   $Id $

   ----------------------------------------------------------------------
   This file is part of SPGL1 (Spectral Projected Gradient for L1).

   Copyright (C) 2007 Ewout van den Berg and Michael P. Friedlander,
   Department of Computer Science, University of British Columbia, Canada.
   All rights reserved. E-mail: <{ewout78,mpf}@cs.ubc.ca>.

   SPGL1 is free software; you can redistribute it and/or modify it
   under the terms of the GNU Lesser General Public License as
   published by the Free Software Foundation; either version 2.1 of the
   License, or (at your option) any later version.

   SPGL1 is distributed in the hope that it will be useful, but WITHOUT
   ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
   or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General
   Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with SPGL1; if not, write to the Free Software
   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301
   USA
   ----------------------------------------------------------------------
*/
#ifndef __ONEPROJECTORCORE_H__
#define __ONEPROJECTORCORE_H__

/* The entries in b are non-negative, those in d strictly positive */
int projectI( double xPtr[], double bPtr[],                double tau, int n );
int projectD( double xPtr[], double bPtr[], double dPtr[], double dOrg[], double tau, int n );

#endif
