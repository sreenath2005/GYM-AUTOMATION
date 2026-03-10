const Payment = require('../models/Payment');
const User = require('../models/User');
const Razorpay = require('razorpay');
const crypto = require('crypto');

const razorpay = new Razorpay({
  key_id: process.env.RAZORPAY_KEY_ID,
  key_secret: process.env.RAZORPAY_KEY_SECRET,
});

// @desc    Create Razorpay Order
// @route   POST /api/payments/razorpay/order
// @access  Private
exports.createRazorpayOrder = async (req, res) => {
  try {
    const { amount, currency = 'INR', planName } = req.body;

    if (!amount) {
      return res.status(400).json({ success: false, message: 'Amount is required' });
    }

    const options = {
      amount: Math.round(amount * 100), // Razorpay expects paise
      currency,
      receipt: `rcpt_${req.user.id.slice(-8)}_${Date.now().toString().slice(-8)}`,
      notes: {
        userId: req.user.id,
        planName: planName || '',
      },
    };

    const order = await razorpay.orders.create(options);

    res.status(200).json({
      success: true,
      data: {
        orderId: order.id,
        amount: order.amount,
        currency: order.currency,
        keyId: process.env.RAZORPAY_KEY_ID,
      },
    });
  } catch (error) {
    console.error('Razorpay order error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Verify Razorpay Payment & save record
// @route   POST /api/payments/razorpay/verify
// @access  Private
exports.verifyRazorpayPayment = async (req, res) => {
  try {
    const { razorpay_order_id, razorpay_payment_id, razorpay_signature, amount, planName, userId } = req.body;

    // Verify signature
    const body = razorpay_order_id + '|' + razorpay_payment_id;
    const expectedSignature = crypto
      .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
      .update(body)
      .digest('hex');

    if (expectedSignature !== razorpay_signature) {
      return res.status(400).json({ success: false, message: 'Payment verification failed' });
    }

    const paymentUserId = userId || req.user.id;

    // Save payment record
    const payment = await Payment.create({
      userId: paymentUserId,
      amount: amount / 100, // convert paise to rupees
      status: 'paid',
      method: 'razorpay',
      description: `Membership: ${planName} | TxnID: ${razorpay_payment_id}`,
    });

    // Update user membership
    await User.findByIdAndUpdate(paymentUserId, { membershipType: planName });

    res.status(200).json({
      success: true,
      message: 'Payment verified and membership activated!',
      data: payment,
    });
  } catch (error) {
    console.error('Razorpay verify error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Create payment
// @route   POST /api/payments
// @access  Private
exports.createPayment = async (req, res) => {
  try {
    const { userId, amount, status, method, description } = req.body;
    const paymentUserId = userId || req.user.id;

    // Check if user is admin or creating their own payment
    if (req.user.role !== 'admin' && paymentUserId !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to create payment for this user',
      });
    }

    const payment = await Payment.create({
      userId: paymentUserId,
      amount,
      status: status || 'pending',
      method: method || 'cash',
      description: description || '',
    });

    const populatedPayment = await Payment.findById(payment._id).populate('userId', 'name email');

    res.status(201).json({
      success: true,
      data: populatedPayment,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get all payments
// @route   GET /api/payments
// @access  Private
exports.getPayments = async (req, res) => {
  try {
    let query = {};

    // If not admin, only show own payments
    if (req.user.role !== 'admin') {
      query.userId = req.user.id;
    } else {
      // Admin can filter by userId
      if (req.query.userId) {
        query.userId = req.query.userId;
      }
    }

    const payments = await Payment.find(query)
      .populate('userId', 'name email phone membershipType')
      .sort({ date: -1 });

    res.status(200).json({
      success: true,
      count: payments.length,
      data: payments,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get single payment
// @route   GET /api/payments/:id
// @access  Private
exports.getPayment = async (req, res) => {
  try {
    const payment = await Payment.findById(req.params.id).populate('userId', 'name email phone');

    if (!payment) {
      return res.status(404).json({
        success: false,
        message: 'Payment not found',
      });
    }

    // Check if user is admin or viewing their own payment
    if (req.user.role !== 'admin' && payment.userId._id.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to view this payment',
      });
    }

    res.status(200).json({
      success: true,
      data: payment,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Update payment
// @route   PUT /api/payments/:id
// @access  Private/Admin
exports.updatePayment = async (req, res) => {
  try {
    const { amount, status, method, description } = req.body;

    const payment = await Payment.findById(req.params.id);

    if (!payment) {
      return res.status(404).json({
        success: false,
        message: 'Payment not found',
      });
    }

    payment.amount = amount !== undefined ? amount : payment.amount;
    payment.status = status || payment.status;
    payment.method = method || payment.method;
    payment.description = description !== undefined ? description : payment.description;

    const updatedPayment = await payment.save();
    const populatedPayment = await Payment.findById(updatedPayment._id).populate('userId', 'name email');

    res.status(200).json({
      success: true,
      data: populatedPayment,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Delete payment
// @route   DELETE /api/payments/:id
// @access  Private/Admin
exports.deletePayment = async (req, res) => {
  try {
    const payment = await Payment.findById(req.params.id);

    if (!payment) {
      return res.status(404).json({
        success: false,
        message: 'Payment not found',
      });
    }

    await payment.deleteOne();

    res.status(200).json({
      success: true,
      message: 'Payment deleted successfully',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get payment stats
// @route   GET /api/payments/stats/:userId
// @access  Private
exports.getPaymentStats = async (req, res) => {
  try {
    const { userId } = req.params;
    const viewUserId = userId || req.user.id;

    // Check if user is admin or viewing their own stats
    if (req.user.role !== 'admin' && viewUserId !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to view this stats',
      });
    }

    // Get pending payments
    const pendingPayments = await Payment.find({
      userId: viewUserId,
      status: 'pending',
    });

    const pendingTotal = pendingPayments.reduce((sum, payment) => sum + payment.amount, 0);

    // Get current month paid amount
    const currentMonth = new Date();
    currentMonth.setDate(1);
    currentMonth.setHours(0, 0, 0, 0);

    const monthlyPayments = await Payment.aggregate([
      {
        $match: {
          userId: viewUserId,
          date: { $gte: currentMonth },
          status: 'paid',
        },
      },
      {
        $group: {
          _id: null,
          total: { $sum: '$amount' },
        },
      },
    ]);

    const monthlyPaid = monthlyPayments.length > 0 ? monthlyPayments[0].total : 0;

    res.status(200).json({
      success: true,
      data: {
        pendingTotal,
        monthlyPaid,
        pendingCount: pendingPayments.length,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Record a cash payment (pending admin confirmation)
// @route   POST /api/payments/cash
// @access  Private
exports.recordCashPayment = async (req, res) => {
  try {
    const { amount, planName } = req.body;
    if (!amount || !planName) {
      return res.status(400).json({ success: false, message: 'Amount and plan name are required' });
    }

    const userId = req.user.id;
    const receiptNo = `CASH-${userId.slice(-6).toUpperCase()}-${Date.now().toString().slice(-6)}`;

    // Save payment record with pending status
    const payment = await Payment.create({
      userId,
      amount,
      status: 'pending',
      method: 'cash',
      description: `Membership: ${planName} | Cash Receipt: ${receiptNo}`,
    });

    // Optimistically update user membership
    await User.findByIdAndUpdate(userId, { membershipType: planName });

    res.status(201).json({
      success: true,
      message: 'Cash payment recorded. Please pay at the gym counter.',
      data: {
        paymentId: payment._id,
        receiptNo,
        amount,
        planName,
        status: 'pending',
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
