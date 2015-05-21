#include <stdio.h>
#include "platform.h"
#include "xuartlite_l.h"
#include "xparameters.h"

#include "xtmrctr.h"

#define TMRCTR_DEVICE_ID	XPAR_TMRCTR_0_DEVICE_ID

/*
 * This example only uses the 1st of the 2 timer counters contained in a
 * single timer counter hardware device
 */
#define TIMER_COUNTER_0	 0
XTmrCtr TimerCounter;
XTmrCtr *TmrCtrInstancePtr = &TimerCounter;

unsigned getnum() {
	char srb = 0;
	unsigned num = 0;
	// skip non digits
	while (srb < '0' || srb > '9')
		srb = XUartLite_RecvByte(STDIN_BASEADDRESS);
	// read all digits
	while (srb >= '0' && srb <= '9') {
		num = num * 10 + (srb - '0');
		srb = XUartLite_RecvByte(STDIN_BASEADDRESS);
	};

	return num;
}
int gcd(int a, int b) {
	int c = a < b ? a : b;
	while (a % c != 0 || b % c != 0) {
		c--;
	}

	return c;
}

int inittimer() {

	int Status;
	/*
	 * Initialize the timer counter so that it's ready to use,
	 * specify the device ID that is generated in xparameters.h
	 */
	Status = XTmrCtr_Initialize(TmrCtrInstancePtr, TMRCTR_DEVICE_ID);
	if (Status != XST_SUCCESS) {
			return XST_FAILURE;
	}

	/*
	 * Perform a self-test to ensure that the hardware was built
	 * correctly, use the 1st timer in the device (0)
	 */
	Status = XTmrCtr_SelfTest(TmrCtrInstancePtr, TIMER_COUNTER_0);


	/*
	 * Enable the Autoreload mode of the timer counters.
	 */
	XTmrCtr_SetOptions(TmrCtrInstancePtr, TIMER_COUNTER_0, XTC_AUTO_RELOAD_OPTION);

	return 0;
}

int main(void) {
	init_platform();
	int N = getnum();
	int nbrs[N];
	int i;
	for (i = 0; i < N; i++) {
		nbrs[i] = getnum();
	}

	u32 Value1;
	u32 Value2;

	int status = inittimer();
	if (status != 0) {
		xil_printf("status: %d", status);
		return 1;
	}


	//start calculation
	int result = nbrs[0];

	/*
	 * Get a snapshot of the timer counter value before it's started
	 * to compare against later
	 */
	Value1 = XTmrCtr_GetValue(TmrCtrInstancePtr, TIMER_COUNTER_0);

	/*
	 * Start the timer counter such that it's incrementing by default
	 */
	XTmrCtr_Start(TmrCtrInstancePtr, TIMER_COUNTER_0);

	/*
	 * Read the value of the timer counter and wait for it to change,
	 * since it's incrementing it should change, if the hardware is not
	 * working for some reason, this loop could be infinite such that the
	 * function does not return
	 */

	for (i = 1; i < N; i++) {
		result = gcd(result, nbrs[i]);
	}
	//end calculation
	Value2 = XTmrCtr_GetValue(TmrCtrInstancePtr, TIMER_COUNTER_0);
	/*
	 * Disable the Autoreload mode of the timer counters.
	 */
	XTmrCtr_SetOptions(TmrCtrInstancePtr, TIMER_COUNTER_0, 0);
	//print result
	xil_printf("Result: %d\r\n", result);
	xil_printf("Time: %d\r\n", Value2-Value1);

	cleanup_platform();

	return 0;
}

