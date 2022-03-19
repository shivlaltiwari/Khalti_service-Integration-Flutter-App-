import 'package:flutter/material.dart';
import 'package:khalti/khalti.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Khalti.init(
    publicKey: "test_public_key_cd068ad0b4b444689a4e86223dd3b6c4",
    enabledDebugging: false,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: KhatiPayment() ,
    );
  }
}
class KhatiPayment extends StatefulWidget {
  const KhatiPayment({ Key? key }) : super(key: key);

  @override
  _KhatiPaymentState createState() => _KhatiPaymentState();
}

class _KhatiPaymentState extends State<KhatiPayment> {

  TextEditingController phNumber = TextEditingController();
  TextEditingController pinCode = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Khalti Payment"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 8),
          child: Column(
            children: [
              TextFormField(
                controller: phNumber,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Phone Number"
                ),
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: pinCode,
                decoration: InputDecoration(
                  labelText: "Pin Code"
                ),
              ),
            ElevatedButton(onPressed: () async{
              var initialPayment = await Khalti.service.initiatePayment(
                request: PaymentInitiationRequestModel(
                  amount:1000 ,
                   mobile: phNumber.text,
                    productIdentity: "pId",
                    productName: "product name",
                     transactionPin: pinCode.text)
              );
              final otp = await showDialog(context: context, 
              barrierDismissible: false,
              builder: (context){
                String? _otp;
                return AlertDialog(
                  title: Text("Enter OTP Pin"),
                  content: TextField(
                    onChanged: (value){
                      _otp=value;
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "OTP"
                    ),
                  ),
                  actions: [
                    SimpleDialogOption(
                      child: Text("Submit"),
                      onPressed: (){
                        Navigator.pop(context,_otp);
                      },
                    )
                  ],
                );
              });
              if (otp != null){
                try{
                  final model = await Khalti.service.confirmPayment(
                    request: PaymentConfirmationRequestModel(
                      confirmationCode: otp, 
                      token: initialPayment.token,
                       transactionPin: pinCode.text)
                  );
                  showDialog(context: context,
                   builder: (context){
                     return AlertDialog(
                       title: Text("Payment Successfully"),
                       content: Text("Varification token is: ${model.token} "),
                     );
                   });
                }catch(e){
                  print(e.toString());
                }
              }
              debugPrint("");
            }, child: Text("Make Payment"))
            ],
          ),
        ),
      ),
      
    );
  }
}
