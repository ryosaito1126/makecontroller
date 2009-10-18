/*
    ChibiOS/RT - Copyright (C) 2006-2007 Giovanni Di Sirio.

    This file is part of ChibiOS/RT.

    ChibiOS/RT is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 3 of the License, or
    (at your option) any later version.

    ChibiOS/RT is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

/**
 * @file AT91SAM7X/mii_lld.h
 * @brief AT91SAM7X low level MII driver header
 * @addtogroup AT91SAM7X_MII
 * @{
 */

#ifndef _MII_LLD_H_
#define _MII_LLD_H_

#include <mii.h>
#include "board.h"

/*===========================================================================*/
/* Driver pre-compile time settings.                                         */
/*===========================================================================*/

/**
 * @brief PHY manufacturer and model.
 */
#if !defined(PHY_HARDWARE) || defined(__DOXYGEN__)
#define PHY_HARDWARE            PHY_MICREL_KS8721
#endif

/*===========================================================================*/
/* PHY specific constants.                                                   */
/*===========================================================================*/

#define PHY_MICREL_KS8721       0
#define PHY_DAVICOM_9161        1

/**
 * @brief Pins latched by the PHY at reset.
 */
#if (PHY_HARDWARE == PHY_MICREL_KS8721)

#define PHY_ADDRESS             1
#define PHY_ID                  MII_KS8721_ID
#define PHY_LATCHED_PINS        (AT91C_PB4_ECRS          | AT91C_PB5_ERX0  | \
                                 AT91C_PB6_ERX1          | AT91C_PB7_ERXER | \
                                 AT91C_PB13_ERX2         | AT91C_PB14_ERX3 | \
                                 AT91C_PB15_ERXDV_ECRSDV | AT91C_PB16_ECOL | \
                                 AT91C_PIO_PB26)
#elif (PHY_HARDWARE == PHY_DAVICOM_9161)

#define PHY_ADDRESS             0
#define PHY_ID                  MII_DM9161_ID
#define PHY_LATCHED_PINS        (AT91C_PB0_ETXCK_EREFCK  | AT91C_PB4_ECRS          | \
                                 AT91C_PB5_ERX0          | AT91C_PB6_ERX1          | \
                                 AT91C_PB7_ERXER         | AT91C_PB13_ERX2         | \
                                 AT91C_PB14_ERX3         | AT91C_PB15_ERXDV_ECRSDV | \
                                 AT91C_PB16_ECOL         | AT91C_PB17_ERXCK)
#endif /* PHY_HARDWARE */

/*===========================================================================*/
/* Driver data structures and types.                                         */
/*===========================================================================*/

/**
 * @brief Type of a PHY register value.
 */
typedef uint16_t phyreg_t;

/**
 * @brief Type of a PHY register address.
 */
typedef uint8_t phyaddr_t;

/*===========================================================================*/
/* External declarations.                                                    */
/*===========================================================================*/

#ifdef __cplusplus
extern "C" {
#endif
  void mii_lld_init(void);
  void mii_lld_reset(MACDriver *macp);
  phyreg_t mii_lld_get(MACDriver *macp, phyaddr_t addr);
  void mii_lld_put(MACDriver *macp, phyaddr_t addr, phyreg_t value);
#ifdef __cplusplus
}
#endif

#endif /* _MII_LLD_H_ */

/** @} */