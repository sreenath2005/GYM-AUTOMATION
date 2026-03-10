const express = require('express');
const router = express.Router();
const {
  createPayment,
  getPayments,
  getPayment,
  updatePayment,
  deletePayment,
  getPaymentStats,
  createRazorpayOrder,
  verifyRazorpayPayment,
  recordCashPayment,
} = require('../controllers/paymentController');
const { protect } = require('../middleware/authMiddleware');
const { authorize } = require('../middleware/roleMiddleware');

// Razorpay routes
router.post('/razorpay/order', protect, createRazorpayOrder);
router.post('/razorpay/verify', protect, verifyRazorpayPayment);

// Cash payment route
router.post('/cash', protect, recordCashPayment);

// General payment routes
router.post('/', protect, createPayment);
router.get('/stats/:userId?', protect, getPaymentStats);
router.get('/', protect, getPayments);
router.get('/:id', protect, getPayment);
router.put('/:id', protect, authorize('admin'), updatePayment);
router.delete('/:id', protect, authorize('admin'), deletePayment);

module.exports = router;
