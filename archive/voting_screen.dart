import 'package:flutter/material.dart';
import 'package:continuehayygov/services/poll_service.dart';
import 'package:continuehayygov/models/poll.dart';

class VotingScreen extends StatelessWidget {
  VotingScreen({super.key});
  final service = PollService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Polls')),
      body: StreamBuilder<List<Poll>>(
        stream: service.getPolls(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final polls = snapshot.data!;
          if (polls.isEmpty) return Center(child: Text('No polls available'));

          return ListView.builder(
            itemCount: polls.length,
            itemBuilder: (context, index) {
              final poll = polls[index];
              final totalVotes = poll.yes + poll.no;
              final yesPercent = totalVotes == 0 ? 0 : (poll.yes / totalVotes) * 100;
              final noPercent = totalVotes == 0 ? 0 : (poll.no / totalVotes) * 100;

              return Card(
                margin: EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(poll.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              try {
                                await service.vote(poll.id, 'yes');
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Vote submitted!')),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                }
                              }
                            },
                            child: Text('Yes'),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () async {
                              try {
                                await service.vote(poll.id, 'no');
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Vote submitted!')),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                }
                              }
                            },
                            child: Text('No'),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text('Yes: ${poll.yes} (${yesPercent.toStringAsFixed(1)}%)'),
                      Text('No: ${poll.no} (${noPercent.toStringAsFixed(1)}%)'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
