const router = require('express').Router();
const { protect } = require('../middleware/auth');
router.get('/profile', protect, (req, res) => res.json({ success: true, data: req.user }));
module.exports = router;
